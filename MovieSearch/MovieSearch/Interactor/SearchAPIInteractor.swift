//
//  SearchAPIInteractor.swift
//  MovieSearch
//
//  Created by Jageloo Yadav on 10/12/21.
//

import Foundation

protocol SearchAPIInteractorOutPut: AnyObject {
    func showMovies()
}

protocol SearchAPIInteractorInput {
    func fetchData(query: String) async
}

class SearchAPIInteractor {
    var presenter: SearchAPIInteractorOutPut?
    var apiClient: APIClientProtocol?
    var movieData: [MovieData] = []
    
    var isInprogress: Bool = false
    var isStubbed = false
    
    init() {
        let config = NetworkConfig(path: "/search/movie")
        let client = APIClient(networkConfig: config)
        self.apiClient = isStubbed ? StubClient() : client
    }
}

extension SearchAPIInteractor: SearchAPIInteractorInput {
    func fetchData(query: String) async {
        guard !isInprogress else { return }
        isInprogress = true
        typealias SResult = Result<SearchResult, Error>
        let result: SResult? = try? await apiClient?.call(request: query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
        self.isInprogress = false
        guard let searchResult = result else {
            return
        }
        switch searchResult {
            case .success(let data):
                self.movieData = data.results
                self.presenter?.showMovies()
            case .failure(let error):
                print(error)
                break
        }
    }
}
