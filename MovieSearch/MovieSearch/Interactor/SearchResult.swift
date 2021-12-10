//
//  SearchResult.swift
//  MovieSearch
//
//  Created by Jageloo Yadav on 11/12/21.
//

import Foundation

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
