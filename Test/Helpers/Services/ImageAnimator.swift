//
//  ImageAnimator.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import CoreImage.CIFilterBuiltins

class ImageAnimator {
    
    private static let kTimescale: Int32 = 600
    
    private let settings: RenderSettings
    private let videoWriter: VideoWriter
    private var images: [UIImage]!
    
    private var frameNum = 0
    
    class func saveToLibrary(videoURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                if !success {
                    print("Could not save video to photo library: \(error)")
                }
            }
        }
    }
    
    class func removeFileAtURL(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        }
        catch _ as NSError {
        }
    }
    
    init(renderSettings: RenderSettings, images: [UIImage]) {
        settings = renderSettings
        videoWriter = VideoWriter(renderSettings: settings)
        self.images = images
    }
    
    func render(effectType: EffectType, completion: (() -> Void)?) {
        ImageAnimator.removeFileAtURL(fileURL: settings.outputURL)
        
        videoWriter.start()
        videoWriter.render(effectType: effectType, appendPixelBuffers: appendPixelBuffers, images: images) {
            ImageAnimator.saveToLibrary(videoURL: self.settings.outputURL)
            completion?()
        }
        
    }
    
    private func appendPixelBuffers(writer: VideoWriter) -> Bool {
        
        let frameDuration = CMTimeMake(value: Int64(ImageAnimator.kTimescale / settings.fps), timescale: ImageAnimator.kTimescale)
        
        while !images.isEmpty {
            
            if writer.isReadyForData == false {
                return false
            }
            
            let image = images.removeFirst()
            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameNum))
            let success = videoWriter.addImage(image: image, withPresentationTime: presentationTime)
            if success == false {
                fatalError("addImage() failed")
            }
            
            frameNum += 1
        }
        
        return true
    }
}
