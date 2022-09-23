//
//  StockDetailsHeaderView.swift
//  Stocks
//
//  Created by Sen Lin on 18/9/2022.
//

import UIKit

class StockDetailsHeaderView: UIView {
    // Chart View
    private let chartView = StockChartView()
    
    private var metricViewModels: [MetricsCollectionViewCell.ViewModel] = []

    // Collection View
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MetricsCollectionViewCell.self, forCellWithReuseIdentifier: MetricsCollectionViewCell.identifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(chartView)
        addSubview(collectionView)
        setUpCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height-100)
        collectionView.frame = CGRect(x: 0, y: frame.height-100, width: frame.width, height: 100)
    }
    
    func configure(chartViewModel: StockChartView.ViewModel, metricsViewModels: [MetricsCollectionViewCell.ViewModel]) {
        chartView.configure(with: chartViewModel)
        chartView.backgroundColor = .systemBackground
        self.metricViewModels = metricsViewModels
        collectionView.reloadData()
    }
    
    
}

extension StockDetailsHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricsCollectionViewCell.identifier, for: indexPath) as? MetricsCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: metricViewModels[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/2, height: 100/3)
    }
    
}
