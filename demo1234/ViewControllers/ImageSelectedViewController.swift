//
//  ImageSelectedViewController.swift
//  demo1234
//
//  Created by macbook on 14/12/18.
//  Copyright © 2018 macbook. All rights reserved.
//

import UIKit

class ImageSelectedViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var selectedImageview: UIImageView!
    
     let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TapGesture()
        
    }
    
    func TapGesture()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(picker1))
        tap.numberOfTapsRequired = 1
        selectedImageview.isUserInteractionEnabled = true
        self.selectedImageview.addGestureRecognizer(tap)
        
    }
    @objc func picker1(sender:UITapGestureRecognizer)
    {
        picker.allowsEditing = true
        picker.delegate = self
        alertcontroller()
    }
    
    func alertcontroller()
    {
        let alert = UIAlertController(title: nil, message: "Choose your source", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { (result : UIAlertAction) -> Void in
                print("Camera selected")
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "Photo library", style: .default) { (result : UIAlertAction) -> Void in
                print("Photo selected")
                self.picker.sourceType = .photoLibrary
                self.present(self.picker, animated: true, completion: nil)
            })
            
            self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        selectedImageview.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startTocreateGif(_sender:UIButton)
    {
        
        if selectedImageview.image == UIImage(named: "TapHere.png")
        {
            let alert = UIAlertController(title: "Error!", message: "Choose an Image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let nav:CameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
            
            nav.bgimage = selectedImageview.image
            
            self.navigationController?.pushViewController(nav, animated: true)
            
        }
        
    }

}
