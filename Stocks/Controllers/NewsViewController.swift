//
//  NewsViewController.swift
//  Stocks
//
//  Created by Sen Lin on 3/8/2022.
//

import UIKit

class NewsViewController: UIViewController {
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        // register cell
        
        return tableView
    }()
    
    private let type: NewsType
    
    enum NewsType{
        case topStories
        case company(symbol: String)
        
        var title: String{
            switch self{
                
            case .topStories:
                return "Top Stories"
            case .company(symbol: let symbol):
                return symbol
            }
        }
    }
    
    init(type: NewsType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTable()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private Functions
    private func setUpTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchNews(){}
    
    private func open(url: URL){}

}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    
}
