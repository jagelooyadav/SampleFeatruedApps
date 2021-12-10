//
//  ViewController.swift
//  MovieSearch
//
//  Created by Jageloo Yadav on 10/12/21.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var apiInteractor = SearchAPIInteractor()

    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let presenter = MovieListPresenter()
        presenter.view = self
        self.apiInteractor.presenter = presenter
        self.apiInteractor.fetchData(query: "query=Harry Potter")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiInteractor.movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as? MovieCell else {
            fatalError("Something went worng")
        }
        let moviewData = apiInteractor.movieData[indexPath.row] as? SearchResult.Result
        cell.moviewData = moviewData
        
        if let url = URL(string: moviewData?.completeURLString ?? "") {
            cell.movieIconView?.download(url: url, completion: { operation in
                guard let data = operation.data else { return }
                cell.movieIconView?.image = UIImage.init(data: data)
                print("operation state == \(operation.state)")
            })
        }
        return cell
    }
}

extension ViewController: MovieListPresenterProtocol {
    func showMovieList() {
        self.tableView.reloadData()
    }
}

