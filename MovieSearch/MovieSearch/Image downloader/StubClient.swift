//
//  StubClient.swift
//  MovieSearch
//
//  Created by Jageloo Yadav on 27/12/21.
//

import Foundation

class StubClient: APIClientProtocol {
    func call<R: Encodable, T: Decodable>(request: R) async throws -> Result<T, Error> {
        return try await withCheckedThrowingContinuation({ continuation in
            
            DispatchQueue.global().async {
                let filePath = Bundle.main.path(forResource: "MovieSearchStub", ofType: "json")
                let data = try? Data(contentsOf: URL(fileURLWithPath: filePath ?? ""))
                guard let data = data else {
                    return continuation.resume(with: .failure(APIError.notReachable))
                }
                
                guard let model = try? JSONDecoder().decode(T.self, from: data) else {
                    continuation.resume(returning: .failure(APIError.notReachable))
                    return
                }
                continuation.resume(returning: .success(model))
            }
        })
    }
}
