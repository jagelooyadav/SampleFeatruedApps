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
    
    private var localCaches: [String: UIImage] = [:]
    
    enum FileLocation {
        case documentDirectory
        case tempDirectory
        case cacheDirectory
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
    
    func download(url: URL, completion: ((DownloadOperation) -> Void)?) {
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
        if let image = localCaches[url.absoluteString] {
            let operation = DownloadOperation(url: url)
            operation.data = image.pngData()
            operation.state = .cached
            completion?(operation)
            return
        }
    
       print("loading started")
       let operation = DownloadOperation(url: url)
        operation.completion = { _ in
            self.maxCuncurent -= 1
            if let data = operation.data {
                let image = UIImage.init(data: data)
                self.localCaches[url.absoluteString] = image
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
