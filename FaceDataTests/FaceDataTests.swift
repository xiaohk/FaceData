//
//  FaceDataTests.swift
//  FaceDataTests
//
//  Created by Jay Wong on 11/24/17.
//  Copyright © 2017 Jay Wong. All rights reserved.
//

import XCTest
@testable import FaceData

class FaceDataTests: XCTestCase {
    let videoPath = "/Users/JayWong/Programs/support/face2face/train.mp4"
    let outputPath = "/Users/JayWong/Programs/support/face2face"
    
    func testAsset(){
        let converter = TrainingConverter(videoPath: videoPath,
                                          outputPath: outputPath,
                                          startSecond: 50,
                                          numOfFrames: 10)
        //converter.extractFrameFromVide()
        converter.convertFrames()
    }
    
}
