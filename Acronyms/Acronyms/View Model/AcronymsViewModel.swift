//
//  AcronymsViewModel.swift
//  Acronyms
//
//  Created by Jageloo Yadav on 15/02/22.
//

import Foundation
import UIKit

protocol BindableObject: AnyObject {
    func reloadData()
}

protocol AcronymsViewModelProtocol {
    var acronyms: [String] { get }
    var searchText: String? { get set }
    func bind(withObject objet: BindableObject?)
}

class AcronymsViewModel: AcronymsViewModelProtocol {
    private(set) var acronyms: [String] = []
    private let service: AcronymService
    
    var searchText: String? {
        didSet {
            self.fetchData()
        }
    }
    
    init(service: AcronymService = AcronymService()) {
        self.service = service
    }
    
    private func fetchData() {
        guard let text = self.searchText, text.count > 1 else { return }
        Task {
            await service.fetchData(query: "sf=\(text)")
            self.acronyms = service.response?.results.compactMap {$0.longForm } ?? []
            DispatchQueue.main.async {
                self.bindingObject?.reloadData()
            }
        }
    }
    weak var bindingObject: BindableObject?
    
    func bind(withObject objet: BindableObject?) {
        self.bindingObject = objet
    }
}
