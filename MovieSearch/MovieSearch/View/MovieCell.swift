//
//  MovieCell.swift
//  MovieSearch
//
//  Created by Jageloo Yadav on 10/12/21.
//

import Foundation
import UIKit

protocol MovieData {
    var title: String? { get }
    var overview: String? { get }
}

class MovieCell: UITableViewCell {
    
    @IBOutlet private(set) weak var movieIconView: UIImageView!
    @IBOutlet private weak var movieNameLabel: UILabel!
    @IBOutlet private weak var movieDescriptionLabel: UILabel!
    
    var moviewData: MovieData? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let data = moviewData else { return }
        movieNameLabel.text = data.title
        movieDescriptionLabel?.text = data.overview
    }
    
    var posterIcon: UIImage? {
        get {
            return self.movieIconView.image
        }
        
        set {
            self.movieIconView.image = newValue
        }
    }
}
