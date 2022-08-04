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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchViewController()
        setUpFloatingPanel()
        setUpTitleView()
    }
    
    // MARK: - Private Functions
    
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
