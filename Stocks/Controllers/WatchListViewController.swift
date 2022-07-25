//
//  ViewController.swift
//  Stocks
//
//  Created by Sen Lin on 21/7/2022.
//

import UIKit

class WatchListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchViewController()
    }
    
    private func setUpSearchViewController(){
        let resultVC = SearchResultViewController()
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
}

extension WatchListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultVC = searchController.searchResultsController as? SearchResultViewController else {
            print("Debug: cannot get query or result VC")
            return
        }
        
        // Optimize to reduce API call
        
        // Call API call to search
        
        // Update the results controller
    }
    
    
}
