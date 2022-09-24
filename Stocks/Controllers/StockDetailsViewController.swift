//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Sen Lin on 1/8/2022.
//

import UIKit
import SafariServices

class StockDetailsViewController: UIViewController {
    
    // MARK: - Properties
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    private var stories: [NewsStory] = []
    private var metrics: Metrics?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return table
    }()
    
    // MARK: - Init
    init(symbol: String, companyName: String, candleStickData: [CandleStick]) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = symbol
        
        setUpCloseButton()
        setUpTable()
        fetchFinancialData()
        fetchNews()

        
        // Show view
        // Financial Data
        // Show Chart / Graph
        // Show News
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(didTapCloseButton))
    }
    
    @objc func didTapCloseButton() {
        dismiss(animated: true)
    }
    
    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width * 0.7 + 100))
        
    }
    
    func fetchFinancialData() {
        
        let group = DispatchGroup()
        
        // Fetch candle sticks if needed
        if candleStickData.isEmpty {
            group.enter()
            
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                    
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print("Debug: cannot fetch market data: \(error)")
                }
            }
        }
        
        // Fetch financial metrics
        group.enter()
        APICaller.shared.searchMetrics(symbol: symbol) { [weak self] result in
            print("Debug: get metrics data")
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metricsData = response.metric
                self?.metrics = metricsData
                
            case .failure(let error):
                print("Debug: cannot get metric model: \(error)")
            }
            
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
        
        renderChart()
    }
    
    func fetchNews() {
        APICaller.shared.fetchNews(for: .company(symbol: symbol)) {[weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let failure):
                print("Debug: cannot fetch data: \(failure)")
            }
        }
    }
    
    func renderChart() {
        let headerView = StockDetailsHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: (view.frame.width * 0.7) + 100
            )
        )
        
        // Configure
        
        
        var viewModels = [MetricsCollectionViewCell.ViewModel]()
        
        if let metric = metrics {
            viewModels.append(.init(name: "52 High", value: "\(metric.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52 High", value: "\(metric.AnnualWeekLow)"))
            viewModels.append(.init(name: "52 Return", value: "\(metric.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metric.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metric.TenDayAverageTradingVolume)"))
        }
        
        print("Debug: metric viewModels: \(viewModels)")
        
        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.backgroundColor = .link
        headerView.configure(chartViewModel: .init(data: candleStickData.reversed().map{ $0.close },
                                                   showLegend: true,
                                                   showAxis: true,
                                                   fillColor: change < 0 ? .systemRed : .systemGreen),
                             metricsViewModels: viewModels)
        tableView.tableHeaderView = headerView
        
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestData = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestData)
              })?.close else {
            return 0
        }
        
        let diff = 1 - (priorClose / latestClose)
        
        return diff
                
    }

}


extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        
        cell.configure(with: .init(model: stories[indexPath.row]))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        
        cell.delegate = self
        cell.configure(with: .init(title: symbol,
                                   shouldShownAddButton: !PersistenceManager.shared.watchlistContains(symbol: symbol)))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
}

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapButton(_ headerView: NewsHeaderView) {
        headerView.isHidden = true
        PersistenceManager.shared.addToWatchlist(symbol: symbol, companyName: companyName)
        
        let alert = UIAlertController(title: "Added to watchlist",
                                      message: "We've successfully added \(companyName) to your watchlist",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        present(alert, animated: true)
    }
}
