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
        tableView.register(WatchlistTableViewCell.self,
                           forCellReuseIdentifier: WatchlistTableViewCell.identifier)
        return tableView
    }()
    
    private var observer: NSObjectProtocol?
    
    static var maxChangeWidth: CGFloat = 0
    
    var searchWorkItem: DispatchWorkItem?
    
    /// Model
    private var watchlistMap: [String: [CandleStick]] = [:]
    private var viewModels = [WatchlistTableViewCell.ViewModel]()
    
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
        setUpObserver()
    }
    
    // MARK: - Private Functions
    
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList,
                                                          object: nil,
                                                          queue: .main, using: { [weak self] _ in
            self?.viewModels.removeAll()
            self?.setUpWatchlistData()
        })
    }
    
    private func setUpTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpWatchlistData(){
        
        print("Debug: begin to set up watch list data")
        
        let symbols = PersistenceManager.shared.watchlist
        
        // concurrently fetch data
        let group = DispatchGroup()
        
        
        for symbol in symbols where watchlistMap[symbol] == nil{
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
                                    changePercentage: NumberFormatter.percentFormatter.string(from: NSNumber(value: changePercentage)) ?? "",
                                    chartViewModel: .init(data: candleStick.reversed().map{ $0.close },
                                                          showLegend: false,
                                                          showAxis: false)))
        }
        
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(for data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else {
            return 0
        }
        
        let diff = 1 - (priorClose / latestClose)
        print("Debug: Current: \(latestClose) Prior: \(priorClose) Diff: \(diff)")
        
        return diff
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        
        return String.formatted(number: closingPrice)
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
        
        searchWorkItem?.cancel()
        
        guard let query = searchController.searchBar.text,
              let resultVC = searchController.searchResultsController as? SearchResultViewController else {
            print("Debug: cannot get query or result VC")
            return
        }
        
        // MARK: - use workItem to perform search API
        let searchItem = DispatchWorkItem {
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let results):
                    // Update the results controller
                    resultVC.update(with: results.result)
                    
                case .failure(let failure):
                    print("Debug: cannot get result: \(failure)")
                }
            }
        }
        
        searchWorkItem = searchItem
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(300)
                                          , execute: searchItem)
        
        
        // MARK: - use timer to reset the search function
        //        searchTimer?.invalidate()
        //        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: { _ in
        //            // Call API call to search
        //            APICaller.shared.search(query: query) { result in
        //                switch result {
        //                case .success(let results):
        //                    // Update the results controller
        //                    resultVC.update(with: results.result)
        //
        //                case .failure(let failure):
        //                    print("Debug: cannot get result: \(failure)")
        //                }
        //            }
        //        })
 
    }
    
    
}

extension WatchListViewController: SearchResultViewControllerDelegate{
    func searchResultViewControllerDidSelect(searchResult: SearchResult) {
        
        // dismiss the keyboard
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        // Present stock details VC
        //        let vc = StockDetailsViewController(symbol: <#T##String#>, companyName: <#T##String#>, candleStickData: <#T##[CandleStick]#>)
        //        vc.title = searchResult.displaySymbol
        //        present(UINavigationController(rootViewController: vc), animated: true)
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
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchlistTableViewCell.identifier, for: indexPath) as? WatchlistTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            // Update persistence
            PersistenceManager.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
            
            // Update viewModels
            viewModels.remove(at: indexPath.row)
            
            // Delete Row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchlistTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModels = viewModels[indexPath.row]
        
        // MARK: - Open Details for Selection
        let vc = StockDetailsViewController(symbol: viewModels.symbol,
                                            companyName: viewModels.companyName,
                                            candleStickData: watchlistMap[viewModels.symbol] ?? [])
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    
}

extension WatchListViewController: WatchListTableViewCellDelegate{
    func didUpdateMaxWidth() {
        tableView.reloadData()
    }
}
