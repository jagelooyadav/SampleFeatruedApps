//
//  AcronymService.swift
//  Acronyms
//
//  Created by Jageloo Yadav on 15/02/22.
//

import Foundation

class AcronymService {
    var apiClient: APIClientProtocol?
    var isInprogress: Bool = false
    var response: AcronymServiceResponse?
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchData(query: String) async {
        guard !isInprogress else { return }
        isInprogress = true
        typealias SResult = Result<[AcronymServiceResponse], Error>
        let result: SResult? = try? await apiClient?.call(request: query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
        self.isInprogress = false
        guard let searchResult = result else {
            self.response = nil
            return
        }
        switch searchResult {
            case .success(let data):
                self.response = data.first
            case .failure(let error):
                print(error)
                break
        }
    }
}
