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
        self.apiInteractor.fetchData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as? MovieCell else {
            fatalError("Something went worng")
        }
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
}

class MovieCell: UITableViewCell {
    @IBOutlet private weak var movieIconView: UIImageView!
    @IBOutlet private weak var movieNameLabel: UILabel!
    @IBOutlet private weak var movieDescriptionLabel: UILabel!
}

