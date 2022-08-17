//
//  ViewController.swift
//  Stocks
//
//  Created by Sen Lin on 21/7/2022.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    private var panel: FloatingPanelController?
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    /// Model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchViewController()
        setUpTableView()
        setUpWatchlistData()
        setUpFloatingPanel()
        setUpTitleView()
        
        APICaller.shared.marketData(for: "GOOG") { result in
            switch result {
            case .success(let response):
                print("Debug: \(response.candleSticks[0])")
            case .failure(let error):
                print("Debug: cannot get market data \(error)")
            }
        }

    }
    
    // MARK: - Private Functions
    
    private func setUpTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpWatchlistData(){
        
        print("Debug: begin to set up watch list data")
        
        let symbols = PersistenceManager.shared.watchlist
        
        // concurrently fetch data
        let group = DispatchGroup()
        
        
        for symbol in symbols{
            group.enter()
            
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print("Debug: something went wrong \(error)")
                }
            }
            
        }
        
        group.notify(queue: .main) { [weak self] in
            print("Debug: group notify")
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    
    private func createViewModels(){
        var viewModels = [WatchlistTableViewCell.ViewModel]()
        
        for (symbol, candleStick) in watchlistMap{
            
            let changePercentage = getChangePercentage(for: candleStick)
            
            viewModels.append(.init(symbol: symbol,
                                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                                    price: getLatestClosingPrice(from: candleStick),
                                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                                    changePercentage: "\(changePercentage)"))
        }
    }
    
    private func getChangePercentage(for data: [CandleStick]) -> Double {
        let priorDate = Date().addingTimeInterval(-3600*24*2)
        
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  Calendar.current.isDate($0.date, inSameDayAs: priorDate)
              })?.close else {
            return 0
        }
        
        print("Debug: Current: \(latestClose) Prior: \(priorClose)")
        
        return 0.0
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        
        return "\(closingPrice)"
    }
    
    private func setUpSearchViewController(){
        let resultVC = SearchResultViewController()
        resultVC.delegate = self
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
    
    private func setUpFloatingPanel(){
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController()
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.delegate = self
        panel.track(scrollView: vc.tableView)
    }
    
}

extension WatchListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultVC = searchController.searchResultsController as? SearchResultViewController else {
            print("Debug: cannot get query or result VC")
            return
        }
        
        // Reset timer
        searchTimer?.invalidate()
        
        // Optimize to reduce API call
        // Kick off new timer
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: { _ in
            // Call API call to search
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let results):
                    // Update the results controller
                    resultVC.update(with: results.result)
                    
                case .failure(let failure):
                    print("Debug: cannot get result: \(failure)")
                }
            }
        })
        
        
        
        
    }
    
    
}

extension WatchListViewController: SearchResultViewControllerDelegate{
    func searchResultViewControllerDidSelect(searchResult: SearchResult) {
        
        // dismiss the keyboard
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        // Present stock details VC
        let vc = StockDetailsViewController()
        vc.title = searchResult.displaySymbol
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}


// Floating Panel Delegate
extension WatchListViewController: FloatingPanelControllerDelegate{
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = (fpc.state == .full)
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // MARK: - Open Details for Selection
    }

    
}
