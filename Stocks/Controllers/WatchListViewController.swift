//
//  ViewController.swift
//  Stocks
//
//  Created by Sen Lin on 21/7/2022.
//

import UIKit

class WatchListViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchViewController()
        setUpTitleView()
    }
    
    // MARK: - Private Functions
    
    private func setUpSearchViewController(){
        let resultVC = SearchResultViewController()
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
    private func setUpTitleView(){
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: navigationController?.navigationBar.frame.height ?? 100))
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 5, width: titleView.frame.width, height: titleView.frame.height - 15))
        titleLabel.text = "Stocks"
        titleLabel.font = .systemFont(ofSize: 32, weight: .semibold)
        titleView.addSubview(titleLabel)
        navigationItem.titleView = titleView
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
