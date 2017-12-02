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
    
    @IBOutlet var outputLabel: NSTextField!
    
    var numOfFrames:Int?
    var processTime:Int?{
        set{
            let process = Int(Double(newValue!) / Double(numOfFrames!) * 100)
            outputLabel.stringValue = "Finished \(process) %"
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
        if startSecondText.intValue >= endSecondText.intValue{
            alertWindow(message: "Bad input",
                        information: "Ending second should be greater than the starting second",
                        button: "All right",
                        style: .warning)
            endSecondText.becomeFirstResponder()
            clearTextFields(field: endSecondText)
            return
        }
        
        numOfFrames = Int(numOfFramesText.intValue)
        processTime = 0
        
        
        let converter = TrainingConverter(videoPath: videoPathText.stringValue ,
                                          outputPath: outputPathText.stringValue,
                                          startSecond: Int(startSecondText.intValue),
                                          endSecond: Int(endSecondText.intValue),
                                          numOfFrames: Int(numOfFramesText.intValue))
        convertFrames(converter: converter)
        
        //clearTextFields()
    }
    
    // +++++++++++++++++++++ Main functions ++++++++++++++++++++++++++
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
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
        alert.addButton(withTitle: "All right")
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
            outputLabel.stringValue = ""
        } else {
            field!.stringValue = ""
        }
    }
    
    // Main functions, sample frames, and extract them
    func convertFrames(converter: TrainingConverter){
        // Dispatch the process in the background
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            [weak self] in
            let num = self!.numOfFrames
            // Smaple the frames
            let frames = converter.sampleFrames()
            
            // Extract frames
            for i in 1...frames.count{
                print(i)
                let maxLength = "\(num ?? 100)".count
                let name = "img" + String(format: "%0\(maxLength)d", i)
                converter.extractFrameFromVide(filename: name, time:frames[i-1])
                
                // Update the UI
                DispatchQueue.main.async {
                    self?.processTime = i
                }
            }
            group.leave()
        }
        group.notify(queue: .main){
            [weak self] in
            self!.alertWindow(message: "Success 🎉",
                              information: "Your process is finished.",
                              button: "Ok",
                              style: .informational)
            //NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: self!.endSecondText)
            self!.clearTextFields()
        }
    }
}

