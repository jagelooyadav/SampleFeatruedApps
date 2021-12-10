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

class SearchAPIInteractor {
    var presenter: SearchAPIInteractorOutPut?
    var apiClient: APIClient?
    var movieData: [MovieData] = []
    
    init() {
        let config = NetworkConfig(path: "/search/movie")
        self.apiClient = APIClient(networkConfig: config)
    }
    
    func fetchData(query: String) {
        typealias SResult = Result<SearchResult, Error>
        self.apiClient?.call(request: query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), completion: { (result: SResult) in
            switch result {
                case .success(let data):
                    self.parse(resutls: data.results)
                case .failure(let error):
                    print(error)
                    break
            }
        })
    }
    
    func parse(resutls: [SearchResult.Result]) {
        self.movieData = resutls
        self.presenter?.showMovies()
    }
}

struct SearchResult: Decodable {
    let page: Int
    let results: [Result]
    
    struct Result: Decodable, MovieData {
        let title: String?
        let overview: String?
        let posterPath: String?
        
        enum CodingKeys: String, CodingKey {
            case title
            case overview
            case posterPath = "poster_path"
        }
        
        var completeURLString: String {
            return "https://image.tmdb.org/t/p/w600_and_h900_bestv2" + (posterPath ?? "")
        }
    }
}
