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
        self.addSearchicon()
        self.title = "Movies"
        let presenter = MovieListPresenter()
        presenter.view = self
        self.apiInteractor.presenter = presenter
    }
    
    private func addSearchicon() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(search))
    }
    
    lazy var searchBar = UISearchBar(frame: .zero)
    
    @objc func search() {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.titleView = searchBar
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = true
        self.searchBar.delegate = self
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

extension ViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return false
    }


    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        guard searchText.count > 1 else { return }
        self.apiInteractor.fetchData(query: "query=\(searchBar.text ?? "")")
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.apiInteractor.fetchData(query: "query=\(searchBar.text ?? "")")
        self.searchBar.resignFirstResponder()
    }
 
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.searchBar.resignFirstResponder()
        self.addSearchicon()
    }
}

