//
//  DownloadOperation.swift
//  ImageCaching
//
//  Created by Jageloo Yadav on 28/10/21.
//
import Foundation

class DownloadOperation: AppOperation {
    private var dowbloadTask: URLSessionDataTask?
    
    var completion: ((Data?) -> Void)?
    var data: Data?
    
    lazy var downloadsSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
        super.init()
        self.name = url.absoluteString
        self.state = .ready
    }
    
    override func start() {
        super.start()
        self.state = .executing
        self.dowbloadTask = downloadsSession.dataTask(with: URLRequest(url: url), completionHandler: { [weak self ] data, _, error in
            guard error == nil, let data = data  else {
                self?.state = .fail
                return
            }
            self?.data = data
            self?.completion?(data)
        })
        self.dowbloadTask?.resume()
    }
    
    override func cancel() {
        super.cancel()
        self.dowbloadTask?.cancel()
        self.data = nil
    }
}

extension DownloadOperation: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("didBecomeInvalidWithError")
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("error == \(challenge)")
        completionHandler(.useCredential, nil)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    }
}
