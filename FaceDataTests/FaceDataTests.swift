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
    
    func testConvert(){
        let converter = TrainingConverter(videoPath: videoPath,
                                          outputPath: outputPath,
                                          startSecond: 50,
                                          numOfFrames: 30)
        converter.convertFrames()
    }
    
    func testSampleFrames(){
        var converter = TrainingConverter(videoPath: videoPath,
                                          outputPath: outputPath,
                                          startSecond: 50,
                                          numOfFrames: 10)
        XCTAssert(converter.sampleFrames().count == 10)
        
        converter = TrainingConverter(videoPath: videoPath,
                                      outputPath: outputPath,
                                      startSecond: 500,
                                      numOfFrames: 100)
        XCTAssert(converter.sampleFrames().count == 100)
        
        converter = TrainingConverter(videoPath: videoPath,
                                      outputPath: outputPath,
                                      startSecond: 30,
                                      numOfFrames: 400)
        XCTAssert(converter.sampleFrames().count == 400)
    }
}
