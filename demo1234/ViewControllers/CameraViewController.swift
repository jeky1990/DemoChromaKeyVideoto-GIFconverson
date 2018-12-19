//
//  CameraViewController.swift
//  demo1234
//
//  Created by macbook on 07/12/18.
//  Copyright © 2018 macbook. All rights reserved.
//

import UIKit
import GPUImage
import Photos
import Regift
import AVFoundation


class CameraViewController: UIViewController{

    @IBOutlet weak var ProgressView : UISlider!
    @IBOutlet weak var renderView : RenderView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var SliderValue: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    var camera:Camera!
    var filter : BasicOperation!
    var isRecording = false
    var movieOutput:MovieOutput? = nil
    var timer = Timer()
    var count : Int = 6
    var threshouldValue : Float = 0.42
    var i : Int = 0
    private var generator:AVAssetImageGenerator!
    var context = CIContext()
    var savevideoURL1 : URL?
    var count1 : Int = 10
    var bgimage : UIImage? = nil
    
    var videoURL:URL = {
        let tempDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print(tempDir)
        let uniqueString = ProcessInfo.processInfo.globallyUniqueString
        let url = URL(fileURLWithPath: tempDir).appendingPathComponent("\(uniqueString).mp4")
        print(url)
        return url
    }()
    
    func checkForAndDeleteFile() {
        let fm = FileManager.default
        let url = videoURL
        let exist = fm.fileExists(atPath: url.path)
        
        if exist {
            print("Delete previous temporary files")
            do {
                try fm.removeItem(at: url as URL)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SliderValue.text = String(count)
        countDownLabel.text = String(count1)
        UserDefaults.setColor(.green, forKey: "colour")
    
        do {
            camera = try Camera(sessionPreset:.hd1920x1080)
            camera.runBenchmark = true
            var lastTarget : ImageSource = camera
            let catstFilter = ChromaKeying()
            catstFilter.smoothing = 0.1
            catstFilter.thresholdSensitivity = threshouldValue
            catstFilter.colorToReplace = UserDefaults.colorForKey("colour")
        
            lastTarget.addTarget(catstFilter)
            lastTarget = catstFilter
            filter = catstFilter
            
            let inputimage = PictureInput(image: bgimage! )  //UIImage(named: "1.jpg")!)
            let blendFilter = AlphaBlend()
            blendFilter.mix = 1
            inputimage.addTarget(blendFilter)
            inputimage.processImage(synchronously: true)
            
            lastTarget.addTarget(blendFilter)
            lastTarget = blendFilter
            filter = blendFilter
            lastTarget.addTarget(renderView)
        
            camera.startCapture()
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.TimerSet), userInfo: nil, repeats: true)
            
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
    }
    
    
    @objc func TimerSet()
    {
        if (count1>0)
        {
            count1 -= 1
            DispatchQueue.main.async {
                self.countDownLabel.text = String(self.count1)
            }
        }
        else
        {
            timer.invalidate()
            countDownLabel.isHidden = true
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setRecordDealyTime), userInfo: nil, repeats: true)
        }
    }
    
    @objc func setRecordDealyTime()
    {
        if (count > 0) {
            
            if count == 6
            {
                do{
                    movieOutput = try MovieOutput(URL:videoURL, size:Size(width:1080, height:1080), liveVideo:true)
                    //camera.audioEncodingTarget = movieOutput
                    if let filter = filter {
                        filter.addTarget(movieOutput!)
                    }
                    movieOutput?.startRecording()
                }catch{
                print("error in recording movie")
                }
            }
            DispatchQueue.main.async {
                self.SliderValue.text = String(self.count)
            }
            count -= 1
            
        }
        else
        {
            timer.invalidate()
            movieOutput?.finishRecording()
           
            //self.camera.audioEncodingTarget = nil
            self.movieOutput = nil
            camera.stopCapture()
            DispatchQueue.main.async {

                self.saveMovieToCameraRoll {
                    print("Save Successfully")
                    self.savetoVideoLoacalStorage()
                    print(self.videoFrameCount(videoURLForGIF: self.videoURL) as Any)
                }
            }
           
            PushToViewGIF()
            
        }
    }
    
    @IBAction func navigatocontoller(_ sender: UIButton) {
        //PushToViewGIF()
    }
    func PushToViewGIF()
    {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "FifthViewController") as! FifthViewController
        nav.localVideoDataURL = self.videoURL
        self.navigationController?.pushViewController(nav, animated: true)
    }

    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
    }
    
    func saveMovieToCameraRoll(_ finishBlock: @escaping () -> Void) {
        
        PHPhotoLibrary.shared().saveVideo(videoURL: videoURL, albumName: "Record Video 1") { (asset) in
            finishBlock()
        }
    }
    
    @IBAction func Threshouldvalue(_ sender: UISlider)
    {
        DispatchQueue.main.async {
            self.threshouldValue = sender.value
            self.SliderValue.text = String(sender.value)
        }
    }
    
    func videoFrameCount(videoURLForGIF:URL) -> Int?
    {
        let asset = AVAsset(url: videoURLForGIF)
        guard let assetTrack = asset.tracks(withMediaType: .video).first else {
            return nil
        }
        
        var assetReader: AVAssetReader?
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        let assetReaderOutputSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        let assetReaderOutput = AVAssetReaderTrackOutput(track: assetTrack,
                                                         outputSettings: assetReaderOutputSettings)
        assetReaderOutput.alwaysCopiesSampleData = false
        assetReader?.add(assetReaderOutput)
        assetReader?.startReading()
        
        var frameCount = 0
        var sample: CMSampleBuffer? = assetReaderOutput.copyNextSampleBuffer()
        _ = CMSampleBufferGetImageBuffer(sample!)
        
        while (sample != nil) {
            frameCount += 1
            sample = assetReaderOutput.copyNextSampleBuffer()
            DispatchQueue.main.async{
               // self.frames.append(samplebufferimage)
            }
            
        }
        
        return frameCount
    }
    
    func savetoVideoLoacalStorage()
    {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let saveVideoURL = URL(fileURLWithPath: path!).appendingPathComponent("sample.mp4")
        if FileManager().fileExists(atPath: path!)
        {
            do{
                let videodata = try Data(contentsOf: videoURL)
                try videodata.write(to: saveVideoURL)
                savevideoURL1 = saveVideoURL
                
            }catch{
                print("Error in save locally")
            }
        }
        
    }
}
