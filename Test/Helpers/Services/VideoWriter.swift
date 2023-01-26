//
//  VideoWriter.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import Foundation
import AVFoundation
import UIKit

class VideoWriter {
    
    private let renderSettings: RenderSettings
    private let outputSize = CGSize(width: 1920, height: 1280)
    private var videoWriter: AVAssetWriter!
    private var videoWriterInput: AVAssetWriterInput!
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    private var asset: AVAsset!
    
    var isReadyForData: Bool {
        return videoWriterInput?.isReadyForMoreMediaData ?? false
    }
    
    class func pixelBufferFromImage(image: UIImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer {
        
        var pixelBufferOut: CVPixelBuffer?
        
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
        if status != kCVReturnSuccess {
            fatalError("CVPixelBufferPoolCreatePixelBuffer() failed")
        }
        
        let pixelBuffer = pixelBufferOut!
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        context!.clear(CGRect(x:0,y: 0,width: size.width,height: size.height))
        
        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit
        
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        
        let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : 0
        let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : 0
        
        context?.draw(image.cgImage!, in: CGRect(x:x,y: y, width: newSize.width, height: newSize.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    init(renderSettings: RenderSettings) {
        self.renderSettings = renderSettings
    }
    
    func start() {
        
        let avOutputSettings: [String: Any] = [
            AVVideoCodecKey: renderSettings.avCodecKey,
            AVVideoWidthKey: NSNumber(value: Float(renderSettings.size.width)),
            AVVideoHeightKey: NSNumber(value: Float(renderSettings.size.height))
        ]
        
        func createPixelBufferAdaptor() {
            let sourcePixelBufferAttributesDictionary = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.size.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.size.height))
            ]
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput,
                                                                      sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        }
        
        func createAssetWriter(outputURL: URL) -> AVAssetWriter {
            guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4) else {
                fatalError("AVAssetWriter() failed")
            }
            
            guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else {
                fatalError("canApplyOutputSettings() failed")
            }
            
            return assetWriter
        }
        
        videoWriter = createAssetWriter(outputURL: renderSettings.outputURL)
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }
        else {
            fatalError("canAddInput() returned false")
        }
        
        // The pixel buffer adaptor must be created before we start writing.
        createPixelBufferAdaptor()
        
        if videoWriter.startWriting() == false {
            fatalError("startWriting() failed")
        }
        
        videoWriter.startSession(atSourceTime: CMTime.zero)
        
        precondition(pixelBufferAdaptor.pixelBufferPool != nil, "nil pixelBufferPool")
    }
    
    func render(effectType: EffectType, appendPixelBuffers: ((VideoWriter) -> Bool)?, images: [UIImage], completion: (() -> Void)?) {
        
        precondition(videoWriter != nil, "Call start() to initialze the writer")
        
        let queue = DispatchQueue(label: "mediaInputQueue")
        videoWriterInput.requestMediaDataWhenReady(on: queue) {
            let isFinished = appendPixelBuffers?(self) ?? false
            if isFinished {
                self.videoWriterInput.markAsFinished()
                self.videoWriter.finishWriting() { [self] in
                    asset = AVAsset(url: renderSettings.outputURL)
                    exportVideoWithAnimation(images: images, effectType: effectType)
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            }
            else {
                // Fall through. The closure will be called again when the writer is ready.
            }
        }
    }
    
    func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
    
    precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
    
    let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: renderSettings.size)
    return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
}
    
    private func exportVideoWithAnimation(images: [UIImage], effectType: EffectType) {
        let composition = AVMutableComposition()
        
        let track = asset?.tracks(withMediaType: AVMediaType.video)
        let videoTrack: AVAssetTrack = track![0] as AVAssetTrack
        let timerange = CMTimeRangeMake(start: CMTime.zero, duration: (asset?.duration)!)
        
        let compositionVideoTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
        
        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }
        
        let size = videoTrack.naturalSize
        
        let videolayer = CALayer()
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.addSublayer(videolayer)
        
        let time = [0.00001, 3, 6, 9, 12]
        
        images.enumerated().forEach {
            
            let nextPhoto = $0.element
            
            let horizontalRatio = CGFloat(self.outputSize.width) / nextPhoto.size.width
            let verticalRatio = CGFloat(self.outputSize.height) / nextPhoto.size.height
            let aspectRatio = min(horizontalRatio, verticalRatio)
            let newSize: CGSize = CGSize(width: nextPhoto.size.width * aspectRatio, height: nextPhoto.size.height * aspectRatio)
            let x = newSize.width < self.outputSize.width ? (self.outputSize.width - newSize.width) / 2 : 0
            let y = newSize.height < self.outputSize.height ? (self.outputSize.height - newSize.height) / 2 : 0
            
            let blackLayer = CALayer()
            
            switch effectType {
            case .leftToRight:
                blackLayer.frame = CGRect(x: -videoTrack.naturalSize.width,
                                          y: 0, width: videoTrack.naturalSize.width,
                                          height: videoTrack.naturalSize.height)
                blackLayer.backgroundColor = UIColor.black.cgColor
    
                let imageLayer = CALayer()
                imageLayer.frame = CGRect(x: x, y: y, width: newSize.width, height: newSize.height)
                imageLayer.contents = $0.element.cgImage
                blackLayer.addSublayer(imageLayer)
    
                let animation = CABasicAnimation()
                animation.keyPath = "position.x"
                animation.fromValue = -videoTrack.naturalSize.width
                animation.toValue = 2 * (videoTrack.naturalSize.width)
                animation.duration = 3
                animation.beginTime = CFTimeInterval(time[$0.offset])
                animation.fillMode = CAMediaTimingFillMode.forwards
                animation.isRemovedOnCompletion = false
                blackLayer.add(animation, forKey: "basic")
            case .bottomToTop:
                blackLayer.frame = CGRect(x: 0, y: -videoTrack.naturalSize.height, width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
                blackLayer.backgroundColor = UIColor.black.cgColor
                
                let imageLayer = CALayer()
                imageLayer.frame = CGRect(x: x, y: y, width: newSize.width, height: newSize.height)
                imageLayer.contents = $0.element.cgImage
                blackLayer.addSublayer(imageLayer)
                
                let animation = CABasicAnimation()
                animation.keyPath = "position.y"
                animation.fromValue = -videoTrack.naturalSize.height
                animation.toValue = 2 * videoTrack.naturalSize.height
                animation.duration = 3
                animation.beginTime = CFTimeInterval(time[$0.offset])
                animation.fillMode = CAMediaTimingFillMode.forwards
                animation.isRemovedOnCompletion = false
                blackLayer.add(animation, forKey: "basic")
            }
            
            
            parentlayer.addSublayer(blackLayer)
        }
        
        let layerComposition = AVMutableVideoComposition()
        layerComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        layerComposition.renderSize = size
        layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: composition.duration)
        let videotrack = composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        instruction.layerInstructions = [layerInstruction]
        layerComposition.instructions = [instruction]
        
        guard let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetHighestQuality) else { return }
        
        assetExport.videoComposition = layerComposition
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = renderSettings.outputURL
        assetExport.exportAsynchronously(completionHandler: {
            switch assetExport.status{
            case  AVAssetExportSession.Status.failed:
                print("failed \(String(describing: assetExport.error))")
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(String(describing: assetExport.error))")
            default:
                print("Exported")
            }
        })
    }
    
}
