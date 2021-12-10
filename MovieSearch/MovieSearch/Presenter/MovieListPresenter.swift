//
//  MovieListPresenter.swift
//  MovieSearch
//
//  Created by Jageloo Yadav on 10/12/21.
//

import Foundation

protocol MovieListPresenterProtocol {
    func showMovieList()
}

class MovieListPresenter {
    var view: MovieListPresenterProtocol?
}

extension MovieListPresenter: SearchAPIInteractorOutPut {
    func showMovies() {
        DispatchQueue.main.async {
            self.view?.showMovieList()
        }
    }
}
