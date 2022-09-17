//
//  SearchResultViewController.swift
//  Stocks
//
//  Created by Sen Lin on 25/7/2022.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject{
    func searchResultViewControllerDidSelect(searchResult: SearchResult)
}

class SearchResultViewController: UIViewController {
    
    weak var delegate: SearchResultViewControllerDelegate?
    private var results: [SearchResult] = []
    
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
    
    public func update(with results: [SearchResult]){
        DispatchQueue.main.async { [weak self] in
            self?.results = results
            self?.searchResultstalbeView.reloadData()
        }
    }
    
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        let model = results[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = model.displaySymbol
        config.secondaryText = model.description
        cell.contentConfiguration = config
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = results[indexPath.row]
        delegate?.searchResultViewControllerDidSelect(searchResult: model)
        let vc = StockDetailsViewController(symbol: model.displaySymbol,
                                            companyName: model.description,
                                            candleStickData: [])
        present(vc, animated: true)
    }
    
    
}
