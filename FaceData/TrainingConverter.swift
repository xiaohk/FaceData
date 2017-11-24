//
//  TrainingConverter.swift
//  FaceData
//
//  Created by Jay Wong on 11/24/17.
//  Copyright © 2017 Jay Wong. All rights reserved.
//

import Foundation

class TrainningConverter{
    var videoPath:String?
    var outputPath:String?
    var numOfFrames = 0
    
    // Init constants
    init(videoPath:String, outputPath:String, numOfFrames:Int){
        self.videoPath = videoPath
        self.outputPath = outputPath
        self.numOfFrames = numOfFrames
    }
    
    func test(){
        print(self.videoPath!)
    }
}
