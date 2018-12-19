//
//  FifthViewController.swift
//  demo1234
//
//  Created by macbook on 12/12/18.
//  Copyright © 2018 macbook. All rights reserved.
//

import UIKit
import Photos
import Regift
import AVFoundation
import MKProgress
import MobileCoreServices


class FifthViewController: UIViewController {
    
    @IBOutlet weak var GIFView: UIImageView!
    
    
    var i : Int = 0
    var context = CIContext()
    var frames : [CVPixelBuffer] = []
    var selectedFrame : [CVPixelBuffer] = []
    var GIFImageArray : [UIImage] = []
    var localVideoDataURL : URL?
    var isGalleryEnable : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MKProgress.config.circleArcPercentage = 0.85
    
    }
    override func viewWillAppear(_ animated: Bool) {
        MKProgress.show()
        DispatchQueue.main.async {
             self.GetFramesFromVideo()
             self.GetSelectedframeFromarray()
             self.ConvertSelectedFrmeintoUiimage()
             self.animatedGif(from: self.GIFImageArray)
             self.retriveGIFfromLocallydirectory()
             MKProgress.hide()
        }
    }
    
    func GetFramesFromVideo()
    {
        //let path = Bundle.main.path(forResource: "8", ofType: "mp4")
        //let demoURL = URL(fileURLWithPath: path!)
        
        let asset = AVAsset(url: localVideoDataURL!)
        let reader = try! AVAssetReader(asset: asset)
        let videotrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let trackReaderOutput = AVAssetReaderTrackOutput(track: videotrack, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA])
        
        reader.add(trackReaderOutput)
        reader.startReading()
        
        
            while let sampleBuffer = trackReaderOutput.copyNextSampleBuffer() {
                autoreleasepool {
                self.i += 1
                print("sample at time \(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))+\(self.i)")
                
                    let imageBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
                     self.frames.append(imageBuffer)
                }
            }
    }
    
    func GetSelectedframeFromarray()
    {
        for i in 0..<frames.count
        {
            if i % 10 == 1
            {
                 autoreleasepool{
                    let image = frames[i]
                    selectedFrame.append(image)
                }
            }
        }
        print(selectedFrame.count)
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func ConvertSelectedFrmeintoUiimage()
    {
        for i in 0..<selectedFrame.count
        {
             autoreleasepool{
                let samplebuffer = selectedFrame[i]
                let ciimage1 : CIImage =  CIImage(cvPixelBuffer: samplebuffer)
                let image : UIImage = self.convert(cmage: ciimage1)
                GIFImageArray.append(image)
            }
        }
        print(GIFImageArray.count)
    }
    
    func animatedGif(from images: [UIImage]) {
        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): 0.06]] as CFDictionary
        let documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL: URL? = documentsDirectoryURL?.appendingPathComponent("animated.gif")
        
        if let url = fileURL as CFURL? {
            if let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, 0, nil) {
                CGImageDestinationSetProperties(destination, fileProperties)
                for image in images {
                    if let cgImage = image.cgImage {
                        CGImageDestinationAddImage(destination, cgImage, frameProperties)
                    }
                }
                if !CGImageDestinationFinalize(destination) {
                    print("Failed to finalize the image destination")
                }
                print("Url = \(fileURL!)")
                
            }
        }
    }
    func retriveGIFfromLocallydirectory()
    {
       let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first

        if FileManager().fileExists(atPath: path!)
        {
            let url = URL(fileURLWithPath: path!).appendingPathComponent("animated.gif")
            
            do {
                let data = try Data(contentsOf: url)
                let advTimeGif = UIImage.gifImageWithData(data)
                self.GIFView.image = advTimeGif
            }catch{}
            
            
            if self.isGalleryEnable {
                PHPhotoLibrary.shared().saveImage(imageURL: url, albumName: "GIF", completion: { (asset) in
                })
            }
     }

    }
}
