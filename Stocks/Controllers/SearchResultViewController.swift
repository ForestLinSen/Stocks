//
//  SearchResultViewController.swift
//  Stocks
//
//  Created by Sen Lin on 25/7/2022.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject{
    func searchResultViewControllerDidSelect(searchResult: String)
}

class SearchResultViewController: UIViewController {
    
    weak var delegate: SearchResultViewControllerDelegate?
    private var results: [String] = []
    
    private let searchResultstalbeView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    // MARK: - Private Functions
    func setUpTableView(){
        view.addSubview(searchResultstalbeView)
        searchResultstalbeView.frame = view.bounds
        searchResultstalbeView.delegate = self
        searchResultstalbeView.dataSource = self
    }
    
    public func update(with results: [String]){
        self.results = results
        searchResultstalbeView.reloadData()
    }
    
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = "AAPL"
        config.secondaryText = "Apple Inc."
        
        cell.contentConfiguration = config
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultViewControllerDidSelect(searchResult: "AAPL")
    }
    
    
}
