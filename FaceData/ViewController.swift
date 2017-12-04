//
//  ViewController.swift
//  FaceData
//
//  Created by Jay Wong on 11/24/17.
//  Copyright © 2017 Jay Wong. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // +++++++++++++++++++++ Interface ++++++++++++++++++++++++++++++
    
    @IBOutlet var videoPathText: NSTextField!
    
    @IBOutlet var outputPathText: NSTextField!
    
    @IBOutlet var startSecondText: NSTextField!
    
    @IBOutlet var endSecondText: NSTextField!
    
    @IBOutlet var numOfFramesText: NSTextField!
    
    @IBOutlet var selectVideoButton: NSButton!
    
    @IBOutlet var selectOutputButton: NSButton!
    
    @IBOutlet var startButton: NSButton!
    
    @IBOutlet var cancelButton: NSButton!
    
    var cancelProcess = false
    var outputPath:String?
    var numOfFrames:Int?
    var processTime:Int?{
        set{
            let process = Int(Double(newValue!) / Double(numOfFrames!) * 100)
            self.view.window?.title = "Processing video: Finished \(process) %"
        }
        get{
            return self.processTime
        }
    }
    
    @IBAction func selectVideo(_ sender: NSButton) {
        browseFiles(title: "Choose your video file", selectDirectory: false,
                    allowedFileTypes: ["mp4"], textField: videoPathText)
    }
    
    @IBAction func selectFolder(_ sender: NSButton) {
        browseFiles(title: "Choose the output folder", selectDirectory: true,
                    allowedFileTypes: ["folder"], textField: outputPathText)
    }
    
    @IBAction func cancelConvert(_ sender: NSButton) {
        self.cancelProcess = true
    }
    
    @IBAction func startConvert(_ sender: NSButton) {
        // Check user input
        if Int(startSecondText.stringValue) == nil && startSecondText.stringValue != ""{
            alertWindow(message: "Bad input",
                        information: "Give an integer value for the starting second, or just leave it empty (default = 0).",
                        button: "All right",
                        style: .warning)
            startSecondText.becomeFirstResponder()
            clearTextFields(field: startSecondText)
            return
        }
        if Int(endSecondText.stringValue) == nil && endSecondText.stringValue != ""{
            alertWindow(message: "Bad input",
                        information: "Give an integer value for the ending second, or just leave it empty (default = video duration time).",
                        button: "All right",
                        style: .warning)
            endSecondText.becomeFirstResponder()
            clearTextFields(field: endSecondText)
            return
        }
        if Int(numOfFramesText.stringValue) == nil && numOfFramesText.stringValue != ""{
            alertWindow(message: "Bad input",
                        information: "Give an integer value for the number of frames, or just leave it empty (default = 100).",
                        button: "All right",
                        style: .warning)
            numOfFramesText.becomeFirstResponder()
            clearTextFields(field: numOfFramesText)
            return
        }
        if startSecondText.intValue >= endSecondText.intValue &&
            startSecondText.stringValue != "" &&
            endSecondText.stringValue != ""
        {
            alertWindow(message: "Bad input",
                        information: "Ending second should be greater than the starting second.",
                        button: "All right",
                        style: .warning)
            endSecondText.becomeFirstResponder()
            clearTextFields(field: endSecondText)
            return
        }
        if videoPathText.stringValue == ""{
            alertWindow(message: "Bad input",
                        information: "Please select the video file.",
                        button: "All right",
                        style: .warning)
            selectVideoButton.becomeFirstResponder()
            return
        }
        if outputPathText.stringValue == ""{
            alertWindow(message: "Bad input",
                        information: "Please select the output directory.",
                        button: "All right",
                        style: .warning)
            selectOutputButton.becomeFirstResponder()
            return
        }
        
        let start = startSecondText.stringValue == "" ? 0 :
                        Int(startSecondText.stringValue)!
        let end = endSecondText.stringValue == "" ? 0 :
                        Int(endSecondText.stringValue)!
        let num = numOfFramesText.stringValue == "" ? 128 :
                        Int(numOfFramesText.stringValue)!
        
        outputPath = outputPathText.stringValue
        numOfFrames = num
        processTime = 0
        
        let converter = TrainingConverter(videoPath: videoPathText.stringValue ,
                                          outputPath: outputPathText.stringValue,
                                          startSecond: start,
                                          endSecond: end,
                                          numOfFrames: num)
        convertFrames(converter: converter)
    }
    
    // +++++++++++++++++++++ Main functions ++++++++++++++++++++++++++
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.title = "Face Data"
        cancelButton.isEnabled = false
    }
    
    // ++++++++++++++++++++++ Helper functions +++++++++++++++++++++++++
    // Pop out a dialog to select files
    func browseFiles(title:String, selectDirectory:Bool, allowedFileTypes:[String],
                     textField:NSTextField){
        
        let dialog = NSOpenPanel()
        dialog.title = title
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = selectDirectory
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = allowedFileTypes
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            // Get the path of the file
            let result = dialog.url
            
            if (result != nil) {
                let path = result!.path
                textField.stringValue = path
            }
        }
    }
    
    // Raise an alert window
    func alertWindow(message: String, information: String, button: String,
                    style: NSAlert.Style){
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = information
        alert.alertStyle = style
        alert.addButton(withTitle: button)
        alert.runModal()
    }
    
    // Clear the textfields
    func clearTextFields(field: NSTextField? = nil){
        if (field == nil){
            videoPathText.stringValue = ""
            outputPathText.stringValue = ""
            startSecondText.stringValue = ""
            endSecondText.stringValue = ""
            numOfFramesText.stringValue = ""
        } else {
            field!.stringValue = ""
        }
    }
    
    // Main functions, sample frames, and extract them
    func convertFrames(converter: TrainingConverter){
        // Dispatch the process in the background
        let group = DispatchGroup()
        self.startButton.isEnabled = false
        self.cancelButton.isEnabled = true
        group.enter()
        DispatchQueue.global(qos: .background).async {
            [weak self] in
            let num = self!.numOfFrames
            // Smaple the frames
            let frames = converter.sampleFrames()
            
            // Extract frames
            for i in 1...frames.count{
                // Cancel this thread if user hits cancel
                if (self!.cancelProcess){
                    break
                }
                
                print(i)
                let maxLength = "\(num ?? 100)".count
                let name = "img" + String(format: "%0\(maxLength)d", i)
                converter.extractFrameFromVideo(filename: name, time:frames[i-1])
                
                // Update the UI
                DispatchQueue.main.async {
                    self?.processTime = i
                }
            }
            group.leave()
        }
        group.notify(queue: .main){
            [weak self] in
            if !self!.cancelProcess{
                self!.alertWindow(message: "Success 🎉",
                                  information: "Your process is finished.",
                                  button: "Ok",
                                  style: .informational)
                self!.cancelProcess = false
                
                // Open the output files
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: self!.outputPath!)
            }
            
            // Button states, and clear the inputs
            self!.clearTextFields()
            self!.view.window?.title = "Face Data"
            self!.cancelButton.isEnabled = false
            self!.startButton.isEnabled = true
        }
    }
}

