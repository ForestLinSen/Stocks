//
//  NewsViewController.swift
//  Stocks
//
//  Created by Sen Lin on 3/8/2022.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .secondarySystemBackground
        // register cell
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        tableView.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return tableView
    }()
    
    private let type: NewsType
    private var stories: [NewsStory] = []
    
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
    
    private func fetchNews(){
        APICaller.shared.fetchNews(for: .topStories) { result in
            switch result {
            case .success(let stories):
                self.stories = stories
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            case .failure(_):
                return
            }
        }
    }
    
    private func open(url: URL){
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier) as? NewsStoryTableViewCell else {
            return UITableViewCell()
        }
        
        let newsStory = stories[indexPath.row]
        cell.configure(with: .init(model: newsStory))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //TODO: - Open News
        let viewModel = stories[indexPath.row]
        guard let url = URL(string: viewModel.url) else {
            presentFailedToOpenAlert()
            return
        }
        open(url: url)
    }
    
    private func presentFailedToOpenAlert(){
        let alert = UIAlertController(title: "Unable to open", message: "We were unable to open the article", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    // header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        
        headerView.configure(with: .init(title: self.type.title, shouldShownAddButton: true))
        
        return headerView
    }
    
    
}
