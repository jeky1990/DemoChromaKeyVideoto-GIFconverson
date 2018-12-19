//
//  deepCopyofFrame.swift
//  demo1234
//
//  Created by macbook on 08/12/18.
//  Copyright © 2018 macbook. All rights reserved.
//

import Foundation
import AVFoundation
import CoreVideo

extension CVPixelBuffer {
    func deepcopy() -> CVPixelBuffer {
        /// 1
        precondition(CFGetTypeID(self) == CVPixelBufferGetTypeID(), "copy() cannot be called on a non-CVPixelBuffer")
        
        /// 2
        let attr = CVBufferGetAttachments(self, .shouldPropagate)
        var _copy : CVPixelBuffer? = nil
        
        /// 3
        CVPixelBufferCreate(
            CFAllocatorGetDefault().takeRetainedValue(),
            CVPixelBufferGetWidth(self),
            CVPixelBufferGetHeight(self),
            CVPixelBufferGetPixelFormatType(self),
            attr,
            &_copy
        )
        
        guard let copy = _copy else { fatalError() }
        
        /// 4
        CVPixelBufferLockBaseAddress(self, .readOnly)
        CVPixelBufferLockBaseAddress(copy, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        /// 5
        let planeCount = CVPixelBufferGetPlaneCount(self)
        
        for plane in 0..<planeCount {
            let dest = CVPixelBufferGetBaseAddressOfPlane(copy, plane)
            let source = CVPixelBufferGetBaseAddressOfPlane(self, plane)
            let height = CVPixelBufferGetHeightOfPlane(self, plane)
            let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(self, plane)
            
            memcpy(dest, source, height * bytesPerRow)
        }
        
        /// 6
        CVPixelBufferUnlockBaseAddress(copy, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        CVPixelBufferUnlockBaseAddress(self, .readOnly)
        
        return copy
    }
}
