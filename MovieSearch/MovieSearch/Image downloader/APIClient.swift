//
//  APIClient.swift
//  LoginScreenArchitecure
//
//  Created by Jageloo Yadav on 26/10/21.
//

import Foundation

protocol APIClientProtocol {
    func call<R: Encodable, T: Decodable>(request: R, completion: ((Result<T, Error>) -> Void)?)
}

class APIClient: APIClientProtocol {
    private let networkConfig: NetworkConfigProtocol
    init(networkConfig: NetworkConfigProtocol = NetworkConfig(path: "", method: "")) {
        self.networkConfig = networkConfig
    }
    
    func call<R: Encodable, T: Decodable>(request: R, completion: ((Result<T, Error>) -> Void)?) {
        let requestData = try? JSONEncoder().encode(request)
        guard let url = URL(string: self.networkConfig.urlString) else {
            completion?(.failure(APIError.invalidResponse))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = networkConfig.method
        if networkConfig.method == "POST" {
            urlRequest.httpBody = requestData
        }
        
        /// basi setup
        urlRequest.addValue(ContentType.applicationJson,
                         forHTTPHeaderField: HTTPHeaderField.contentType)
        urlRequest.addValue("dev", forHTTPHeaderField: "username")
        urlRequest.addValue("giz", forHTTPHeaderField: "password")//AuthType
        urlRequest.addValue("Basic", forHTTPHeaderField: "AuthType")
        
        let username = "dev"
        let password = "giz"
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        urlRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        //
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard let httpsResponse = response as? HTTPURLResponse,
                  httpsResponse.statusCode == 200,
                  let data = data else {
                completion?(.failure(APIError.notReachable))
                return
            }
            
            guard let model = try? JSONDecoder().decode(T.self, from: data) else {
                completion?(.failure(APIError.notReachable))
                return
            }
            completion?(.success(model))
            
        }).resume()
    }
}

protocol NetworkConfigProtocol {
    var baseURL: String { get }
    var path: String? { get }
    var method: String { get }
}

extension NetworkConfigProtocol {
    var urlString: String {
        return baseURL + (path ?? "")
    }
}

struct NetworkConfig: NetworkConfigProtocol {
    var baseURL: String = "https://new.gizmogul.com/api/v1"
    var path: String?
    var method: String = "GET"
    
    init(path: String, method: String = "GET") {
        self.path = path
        self.method = method
    }
}

enum APIError: Error {
    case invalidResponse
    case notReachable
    
    var errorDescription: String {
        switch self {
            case .invalidResponse:
                return "Something went wrong"
            case .notReachable:
                return "Server is down"
        }
    }
}
