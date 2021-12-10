//
//  ImageDownloader.swift
//  ImageCaching
//
//  Created by Jageloo Yadav on 28/10/21.
//

import Foundation
import UIKit

actor DataCaching {
    var localCaches: [String: UIImage] = [:]
    var operationMapping: [String: DownloadOperation] = [:]
}

class ImgeDownloader {
    static let shared = ImgeDownloader()
    private var operationMapping: [String: DownloadOperation] = [:]
    private let group = DispatchGroup()
    private var folder = "ImageCaching"
    private var maxCuncurent = 0
    let operationQueue = OperationQueue()
    
    private var localCaches: [String: UIImage] = [:]
    private var actor = DataCaching()
    
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
        Task {
            if let downloadOperation = await self.actor.operationMapping[url.absoluteString], downloadOperation.isExecuting {
                completion?(downloadOperation)
                return
            }
            
            //Check if data is stored in operation object
            if let downloadOperation = await self.actor.operationMapping[url.absoluteString], downloadOperation.data != nil {
                downloadOperation.state = .downloaded
                completion?(downloadOperation)
                return
            }
            
            if let image = await self.actor.localCaches[url.absoluteString] {
                let operation = DownloadOperation(url: url)
                operation.data = image.pngData()
                operation.state = .cached
                completion?(operation)
                return
            }
        }
       print("loading started")
       let operation = DownloadOperation(url: url)
        operation.completion = { _ in
            if let data = operation.data {
                let image = UIImage.init(data: data)
                
                DispatchQueue.main.async(flags: .barrier) {
                    self.localCaches[url.absoluteString] = image
                }
            }

            operation.state = .finished
            
            completion?(operation)
        }
        operationQueue.addOperation(operation)
    }
    
    func clearCache() {
        Task {
            var mapping = await self.actor.operationMapping
            mapping.removeAll()
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
