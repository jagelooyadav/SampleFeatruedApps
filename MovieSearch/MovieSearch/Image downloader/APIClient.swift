//
//  APIClient.swift
//  LoginScreenArchitecure
//
//  Created by Jageloo Yadav on 26/10/21.
//

import Foundation

protocol APIClientProtocol {
    func call<R: Encodable, T: Decodable>(request: R) async throws -> Result<T, Error>
}

class APIClient {
    private let networkConfig: NetworkConfigProtocol
    
    init(networkConfig: NetworkConfigProtocol = NetworkConfig(path: "", method: "")) {
        self.networkConfig = networkConfig
    }
}

extension APIClient: APIClientProtocol {
    func call<R: Encodable, T: Decodable>(request: R) async throws -> Result<T, Error> {
        let requestData = try? JSONEncoder().encode(request)
        let urlString: String
        if self.networkConfig.isQuery, let request = request as? String {
            urlString = self.networkConfig.urlString + "&\(request)"
        } else {
            urlString = self.networkConfig.urlString
        }
        guard let url = URL(string: urlString) else {
            return .failure(APIError.invalidResponse)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = networkConfig.method
        if networkConfig.method == "POST" {
            urlRequest.httpBody = requestData
        }
        
        return try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                guard let httpsResponse = response as? HTTPURLResponse,
                      httpsResponse.statusCode == 200,
                      let data = data else {
                          return continuation.resume(with: .failure(APIError.notReachable))
                      }
                
                guard let model = try? JSONDecoder().decode(T.self, from: data) else {
                    continuation.resume(returning: .failure(APIError.notReachable))
                    return
                }
                continuation.resume(returning: .success(model))
                
            }).resume()
        })
    }
}

protocol NetworkConfigProtocol {
    var baseURL: String { get }
    var path: String? { get }
    var method: String { get }
    var isQuery: Bool { get set }
    var apiKey: String { get }
}

extension NetworkConfigProtocol {
    var urlString: String {
        return baseURL + ((path ?? "") + "?api_key=\(self.apiKey)")
    }
}

struct NetworkConfig: NetworkConfigProtocol {
    
    let apiKey = "###API KEY###"
    var isQuery = true
    var baseURL: String = "####### API base URL"
    var path: String?
    var method: String = "GET"
    
    init(path: String, method: String = "GET", isQuery: Bool = true) {
        self.path = path
        self.method = method
        self.isQuery = isQuery
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
