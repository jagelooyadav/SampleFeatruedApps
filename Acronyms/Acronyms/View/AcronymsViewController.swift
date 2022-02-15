//
//  ViewController.swift
//  Acronyms
//
//  Created by Jageloo Yadav on 15/02/22.
//

import UIKit

class AcronymsViewController: UIViewController {
    
    private lazy var viewModel: AcronymsViewModelProtocol = AcronymsViewModel()

    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSearchicon()
        self.title = "Acronyms"
        viewModel.bind(withObject: tableView)
    }
    
    private func addSearchicon() {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.titleView = searchBar
        
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = true
        self.searchBar.delegate = self
    }
    
    lazy var searchBar = UISearchBar(frame: CGRect.init(origin: .zero, size: CGSize.init(width: .greatestFiniteMagnitude, height: 40.0)))
}

extension AcronymsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.acronyms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.acronyms[indexPath.row]
        return cell
    }
}

extension AcronymsViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 1 else { return }
        viewModel.searchText = searchText
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        viewModel.searchText = searchBar.text
    }
 
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}
extension UITableView: BindableObject {}



