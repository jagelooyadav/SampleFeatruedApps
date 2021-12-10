//
//  RestAPI.swift
//  PhoneEstimator
//
//  Created by Jageloo Yadav on 18/06/20.
//  Copyright © 2020 Jageloo. All rights reserved.
//

import UIKit

import Foundation

public enum HTTPMethodType : String {
    
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
    public init(type :String?) {
        
        if let type = type {
        
            self = HTTPMethodType(rawValue: type) ?? .get
        } else {
            self = .get
        }
        
    }
}

public enum HTTPHeaderField {
    
    static let contentType = "Content-Type"
}

public enum ContentType {
    
    static let applicationJson = "application/json"
}

public enum EnvironmentURL {
    static let local = "http://162.13.104.78/"
    static let URI_HTTP = "https://new.gizmogul.com/api/v1/product/unit/test/add"
    static let websiteURL = "http://i-wigt.com"
}

class RestAPIOperation: Operation {
    
    enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    private var _state: State = .ready
    
    var state: State {
        get {
            return _state
        }
        set {
            let oldValue = _state
            willChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: newValue.rawValue)
            
            _state = newValue
            
            willChangeValue(forKey: newValue.rawValue)
            didChangeValue(forKey: oldValue.rawValue)
        }
    }
    
    var _isCancelled = false
    
    private var isCompleted = false
    
    override func start() {
        self.state = .executing
    }
    
    override func cancel() {
        _isCancelled = true
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isCancelled: Bool {
        return _isCancelled
    }
    
    override var isFinished: Bool {
        state == .finished
    }
}

class ServiceConsumer: RestAPIOperation {
    
    private let baseURL: String
    private let path: String?
    private var params: json?
    private let type: HTTPMethodType
    private let complitionHandler: complition?
    init(baseURL :String = EnvironmentURL.URI_HTTP,
         path :String?,
         params :json? = nil,
         type :HTTPMethodType = .post,
         complitionHandler: complition?) {
        self.baseURL = baseURL
        self.path = path
        self.params = params
        self.type = type
        self.complitionHandler = complitionHandler
    }
    override func start() {
        super.start()
        if params == nil {
            params = [:]
        }
        params?["apiKey"] = "86bb1138-4ced-430b-8c42-d59e53354ebd"
        let path = ""
        let url = baseURL.appending(path).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? path
        guard let URL = URL(string: url) else {
            if let complitionHandler = complitionHandler
            {
                self.state = .finished
                complitionHandler(nil, ServiceError.invalidURL)
            }
            return
        }
        
        var request = URLRequest(url: URL)
        request.httpMethod = type.rawValue
        request.addValue(ContentType.applicationJson,
                         forHTTPHeaderField: HTTPHeaderField.contentType)
        request.addValue("dev", forHTTPHeaderField: "username")
        request.addValue("giz", forHTTPHeaderField: "password")//AuthType
        request.addValue("Basic", forHTTPHeaderField: "AuthType")
        
        let username = "dev"
        let password = "giz"
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        request.httpMethod = "POST"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        if type == .post, let params = params
        {
            
            do
            {
                let body = try JSONSerialization.data(withJSONObject: params,
                                                      options: .prettyPrinted)
                request.httpBody = body
            }
            catch
            {
                
                if let complitionHandler = complitionHandler
                {
                    complitionHandler(nil, ServiceError.invalidRequestParamaters)
                }
                self.state = .finished
            }
        }
        
        let task :URLSessionDataTask = URLSession.shared.dataTask(with: request)
        {
            (data :Data?, resp :URLResponse?, err :Error?) in
            
            if let error = err,
               let complitionHandler = self.complitionHandler
            {
                complitionHandler(nil, error)
                self.state = .finished
            }
            
            do
            {
                guard let data = data else { return }
                let response = String.init(data: data, encoding: .utf8)
                print("response in string == \(response)");
                let json = try JSONSerialization.jsonObject(with: data,
                options: []) as? [String : AnyHashable]
                
                if let complitionHandler = self.complitionHandler
                {
                    if json?["status"] as? String == "OK" {
                        complitionHandler(json, nil)
                    } else {
                        complitionHandler(nil, ServiceError.invalidResponse)
                    }
                }
                self.state = .finished
            }
            catch
            {
                
                if let complitionHandler = self.complitionHandler
                {
                    complitionHandler(nil, ServiceError.invalidResponse)
                }
                self.state = .finished
            }
        }
        task.resume()
    }
    
    public typealias json = [String : AnyHashable]
    public typealias complition = (_ response :json?, _ error :Error?) -> Void
    
    public enum ServiceError : Error {
        
        case invalidURL
        case invalidResponse
        case invalidRequestParamaters
        
    }
}

