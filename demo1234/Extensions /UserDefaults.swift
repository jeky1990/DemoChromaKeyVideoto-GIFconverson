//
//  UserDefaults.swift
//  demo1234
//
//  Created by macbook on 07/12/18.
//  Copyright © 2018 macbook. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

extension UserDefaults{
    
    class func keyExists(_ key:String) -> Bool {
        let object:Any? = self.standard.object(forKey: key)
        if object != nil {
            return true
        }
        return false
    }
    
    class func colorForKey(_ key:String) -> Color {
        let theOblect = self.standard.object(forKey: key) as AnyObject
        
        if theOblect is String {
            let str = theOblect as! String
            let arrString = str.split(separator: ",")
            
            if let h = Double(String(arrString[0]).trimmingCharacters(in: CharacterSet.whitespaces)), let s = Double(String(arrString[1]).trimmingCharacters(in: CharacterSet.whitespaces)), let b = Double(String(arrString[2]).trimmingCharacters(in: CharacterSet.whitespaces)) {
                return Color(red: Float(h), green: Float(s), blue: Float(b))
            }
        }
        
        return Color(red: 0, green: 1, blue: 0)
    }
    class func setColor(_ color:UIColor, forKey key:String) {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        let coordString = "\(fRed), \(fGreen), \(fBlue)"
        self.standard.set(coordString, forKey: key)
        self.standard.synchronize()
    }
}
