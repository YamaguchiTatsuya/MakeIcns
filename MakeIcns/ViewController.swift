//
//  ViewController.swift
//  MakeIcns
//
//  Created by TATSUYA YAMAGUCHI on 2020/07/24.
//  Copyright © 2020 TATSUYA YAMAGUCHI. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    private let sourceImagefileName = "soucrceImage.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        start()
    }
    
    private func start() {
        
        let outputDir = makeOutputDir()
        
        makeImages(to: outputDir)
        
        makeIcnsFile(with: outputDir)
    }
    
    //MARK: -
    
    private func makeOutputDir() -> URL {
        
        //check path to desktop
        let desktop = "/Users/yourUsersName/Desktop/"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: desktop) {
            print("ERROR! nof found desktop: \(desktop)")
            abort()
        }
        
        // make directory name
        let dirName = "icon_\(makeTimeString()).iconset"
        let outputDir = URL(fileURLWithPath: desktop + dirName)
        
        // make direcotry
        do {
            try fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        
        return outputDir
    }
    
    private func makeTimeString() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"
        let dateText = formatter.string(from: date)
        
        return dateText
    }
    
    //MARK: -
    
    private func makeImages(to outputDir: URL) {
        
        func Make(_ fileName: String, _ image: NSImage) {
            let url = outputDir.appendingPathComponent(fileName)
            savePNGImageFrom(image, url: url)
        }
        
        guard let sourceImage = NSImage(named: sourceImagefileName) else {
            print("ERROR! no image file: \(sourceImagefileName)")
            return
        }
        
        let size = sourceImage.size
        if Int(size.width) != 1024 || Int(size.height) != 1024 {
            print("ERROR! image size shoud be 1024x1024 but size=\(size)")
            return
        }
        
        
        let image512 = sourceImage.resize(CGSize(width: 512, height: 512))
        let image256 = sourceImage.resize(CGSize(width: 256, height: 256))
        let image128 = sourceImage.resize(CGSize(width: 128, height: 128))
        let image64 = sourceImage.resize(CGSize(width: 64, height: 64))
        let image32 = sourceImage.resize(CGSize(width: 32, height: 32))
        let image16 = sourceImage.resize(CGSize(width: 16, height: 16))
        
        Make("icon_512x512@2x.png", sourceImage)
        Make("icon_512x512.png", image512)
        Make("icon_256x256@2x.png", image512)
        Make("icon_256x256.png", image256)
        Make("icon_128x128@2x.png", image256)
        Make("icon_128x128.png", image128)
        Make("icon_32x32@2x.png", image64)
        Make("icon_32x32.png", image32)
        Make("icon_16x16@2x.png", image32)
        Make("icon_16x16.png", image16)
    }
    
    private func savePNGImageFrom(_ image: NSImage, url: URL) {
        
        guard let iData = image.tiffRepresentation else {
            abort()
        }
        guard let imageRep = NSBitmapImageRep(data: iData) else {
            abort()
        }
        guard let imageData = imageRep.representation(using: .png,
                                                      properties: [:]) else {
                                                        abort()
        }
        do {
            try imageData.write(to: url)
        } catch {
            print(error)
        }
    }
    
    //MARK: -
    
    private func makeIcnsFile(with url: URL) {
        
        let _ = shell("iconutil", "-c", "icns", url.path)
    }

    private func shell(_ args: String...) -> Int32 {
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
        
        //bash - How do I run an terminal command in a swift script? (e.g. xcodebuild) - Stack Overflow https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild
    }
}

//MARK: -

extension NSImage {
    
    func resize(_ newSize: CGSize) -> NSImage {
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        let rect = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let fromRect = NSRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect, from: fromRect, operation: NSCompositingOperation.sourceOver,
                   fraction: 1.0)
        
        newImage.unlockFocus()
        newImage.size = newSize

        return newImage
    }
}
