//
//  TrainingConverter.swift
//  FaceData
//
//  Created by Jay Wong on 11/24/17.
//  Copyright © 2017 Jay Wong. All rights reserved.
//

import Foundation
import AVFoundation
import Vision


class TrainingConverter{
    
    var videoPath:String?
    var outputPath:String?
    var startSecond = 0
    var numOfFrames = 0
    var asset:AVAsset
    var imageGenerator:AVAssetImageGenerator
    var originPath:URL
    var landmarkPath:URL
    
    let timeScale = 10
    
    // Init properties
    init(videoPath:String, outputPath:String, startSecond:Int, numOfFrames:Int){
        self.videoPath = videoPath
        self.outputPath = outputPath
        self.startSecond = startSecond
        self.numOfFrames = numOfFrames
        
        // Create generator to extract frame
        let videoURL = URL(fileURLWithPath: self.videoPath!)
        self.asset = AVAsset(url: videoURL)
        self.imageGenerator = AVAssetImageGenerator(asset: asset)
        
        // Create image destination
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory,
                                                  in: .userDomainMask)[0]
        // Create /origin and /landmark directories
        self.originPath = supportURL.appendingPathComponent("origin")
        self.landmarkPath = supportURL.appendingPathComponent("landmark")
        
        do {
            try FileManager.default.createDirectory(
                at: self.originPath, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(
                at: self.landmarkPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Didn't created directory, error: \(error.localizedDescription)");
        }
    }
    
    // Main functions, sample frames, and extract them
    func convertFrames(){
        print(self.asset.duration)
        extractFrameFromVide(filename: "img001", second: 400)
    }
    
    // Extract a CGImage (frame) from the video at the given time
    func extractFrameFromVide(filename:String, second:Int){

        let time = CMTimeMake(Int64(second), Int32(timeScale))
        var generatedCGImage:CGImage
        
        // Extract the frame at that time
        do {
            generatedCGImage = try self.imageGenerator.copyCGImage(at: time,
                                                                   actualTime: nil)
            // Detect and draw the face landmark
            if let landmarkCGImage = self.detectLandmark(image: generatedCGImage){
                let originDestination = CGImageDestinationCreateWithURL(
                    self.originPath.appendingPathComponent(filename+".png") as CFURL,
                    kUTTypePNG, 1, nil)!
                CGImageDestinationAddImage(originDestination, generatedCGImage, nil)
                CGImageDestinationFinalize(originDestination)
                
                let landmarkDestination = CGImageDestinationCreateWithURL(
                    self.landmarkPath.appendingPathComponent(filename+"lm.png") as CFURL,
                    kUTTypePNG, 1, nil)!
                CGImageDestinationAddImage(landmarkDestination, landmarkCGImage, nil)
                CGImageDestinationFinalize(landmarkDestination)
            } else {
                // No face detected in this frame
                return
            }
        } catch {
            print("Failed to extract frame with error : \(error.localizedDescription)")
            return
        }
    }
    
    // Detect the landmark from the given CGImage, and create a traning example
    // The tranning example will be the land mark points draw on a black background
    func detectLandmark(image:CGImage) -> CGImage?{
        var landmarkCGImage:CGImage?
        
        let faceLandmark = VNDetectFaceLandmarksRequest { (request, error) in
            if error != nil{
                print("Error in face landmark detection reqeust \(error.debugDescription)")
            }
            if let results = request.results as? [VNFaceObservation] {
                if results.count == 0 {
                    // No face in this frame
                    return
                }
                // Might have multiple faces, we only want one face
                let observation = results[0]
                let boundingBox = observation.boundingBox
                
                var points:[VNFaceLandmarkRegion2D] = []
                if let landmarks = observation.landmarks {
                    // Add each observation to the points array seprately, so we can
                    // connect each part individually
                    if let faceContour = landmarks.faceContour {
                        points.append(faceContour)
                    }
                    if let leftEye = landmarks.leftEye {
                        points.append(leftEye)
                    }
                    if let rightEye = landmarks.rightEye {
                        points.append(rightEye)
                    }
                    if let nose = landmarks.nose {
                        points.append(nose)
                    }
                    if let noseCrest = landmarks.noseCrest {
                        points.append(noseCrest)
                    }
                    if let medianLine = landmarks.medianLine {
                        points.append(medianLine)
                    }
                    if let outerLips = landmarks.outerLips {
                        points.append(outerLips)
                    }
                    if let leftEyebrow = landmarks.leftEyebrow {
                        points.append(leftEyebrow)
                    }
                    if let rightEyebrow = landmarks.rightEyebrow {
                        points.append(rightEyebrow)
                    }
                    if let innerLips = landmarks.innerLips {
                        points.append(innerLips)
                    }
                    if let leftPupil = landmarks.leftPupil {
                        points.append(leftPupil)
                    }
                    if let rightPupil = landmarks.rightPupil {
                        points.append(rightPupil)
                    }
                }
                // Draw the CGImage
                landmarkCGImage = self.drawLandmarkds(source: image,
                                                      points: points,
                                                      boundingBox: boundingBox)
            }
        }
        
        // Call the request
        let vnImage = VNImageRequestHandler(cgImage: image, options: [:])
        try? vnImage.perform([faceLandmark])
        return landmarkCGImage
    }
    
    // Draw the landmarks on a new CGImage
    func drawLandmarkds(source:CGImage, points:[VNFaceLandmarkRegion2D],
                        boundingBox:CGRect) -> CGImage{
        // UIKit is not supported on MacOS, so we have to use a CGContext
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil,
                                width: source.width,
                                height: source.height,
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)!
        
        // To the left top point
        context.translateBy(x: 0, y: CGFloat(source.height))
        // Flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        // Make the pixel look more smooth
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        // Fill the background color to black
        context.setFillColor(CGColor.black)
        context.fill(CGRect(x: 0, y: 0, width: context.width, height: context.height))
        
        return context.makeImage()!
    }
}














