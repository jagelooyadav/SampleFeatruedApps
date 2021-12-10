//
//  ImageDownloader.swift
//  ImageCaching
//
//  Created by Jageloo Yadav on 28/10/21.
//

import Foundation
import UIKit

class ImgeDownloader {
    static let shared = ImgeDownloader()
    private var operationMapping: [String: DownloadOperation] = [:]
    private let group = DispatchGroup()
    private var folder = "ImageCaching"
    private var maxCuncurent = 0
    let operationQueue = OperationQueue()
    
    enum FileLocation {
        case documentDirectory
        case tempDirectory
        case cacheDirectory
    }
    
    private var folderPath: URL? {
        switch self.fileLocation {
            case .cacheDirectory:
                return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(folder)
            case .documentDirectory:
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(folder)
                
            case .tempDirectory:
                return nil
        }
    }
    
    private var fileLocation: FileLocation = .documentDirectory
    
    func download(urls: [URL], completion: (() -> Void)?) {
        for url in urls {
            group.enter()
            self.download(url: url) { [weak self] operation in
                self?.group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            completion?()
        }
    }
    
    func download(fileLocation: FileLocation = .documentDirectory,
                  url: URL, completion: ((DownloadOperation) -> Void)?) {
        DispatchQueue.global().async(flags: .barrier) {
            //self.fileLocation = fileLocation
        }
        self.fileLocation = fileLocation
        // Return if operation is already in progress
        if let downloadOperation = operationMapping[url.absoluteString], downloadOperation.isExecuting {
            completion?(downloadOperation)
            return
        }
        
        //Check if data is stored in operation object
        if let downloadOperation = operationMapping[url.absoluteString], downloadOperation.data != nil {
            downloadOperation.state = .downloaded
            completion?(downloadOperation)
            return
        }
        
        // Check if image is saved in directory
        if let directoryPath = self.folderPath,
           FileManager.default.fileExists(atPath: directoryPath.relativePath + "/" + url.lastPathComponent) {
            let fileURL = URL(fileURLWithPath: directoryPath.relativePath + "/" + url.lastPathComponent)
            let operation = DownloadOperation(url: url)
            operation.data = try? Data(contentsOf: fileURL)
            print("file already cached at path === \(fileURL)")
            operation.state = .cached
            completion?(operation)
            return
        }
        
        if maxCuncurent > 10 {
            return
        }
       maxCuncurent += 1
        print("loading started")
       let operation = DownloadOperation(url: url)
        operation.completion = { _ in
            self.maxCuncurent -= 1
            if let directoryPath = self.folderPath, !FileManager.default.fileExists(atPath: directoryPath.relativePath, isDirectory: nil) {
                try? FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
                print("file created")
            }
            if let directoryPath = self.folderPath {
                let fileURL = URL(fileURLWithPath: directoryPath.relativePath + "/" + url.lastPathComponent)
                try? operation.data?.write(to: fileURL)
            }
            operation.state = .finished
            
            completion?(operation)
        }
        operationQueue.addOperation(operation)
    }
    
    func clearCache() {
        DispatchQueue.global().async(flags: .barrier) {
            self.operationMapping.removeAll()
        }
    }
}

extension UIImageView {
    func download(url: URL, completion: ((DownloadOperation) -> Void)?) {
        ImgeDownloader.shared.download(url: url) { operation in
            DispatchQueue.main.async(flags: .barrier) {
                if let data = operation.data {
                    print("loaded sucess fully")
                    self.image = UIImage(data: data)
                }
                completion?(operation)
            }
        }
    }
}
