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
    
    @IBAction func selectVideo(_ sender: NSButton) {
        browseFiles(title: "Choose your video file", selectDirectory: false,
                    allowedFileTypes: ["mp4"], textField: videoPathText)
    }
    
    @IBAction func selectFolder(_ sender: NSButton) {
        browseFiles(title: "Choose the output folder", selectDirectory: true,
                    allowedFileTypes: ["folder"], textField: outputPathText)
    }
    
    @IBAction func startConvert(_ sender: NSButton) {
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
}

