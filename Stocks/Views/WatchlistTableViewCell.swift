//
//  WatchlistTableViewCell.swift
//  Stocks
//
//  Created by Sen Lin on 13/8/2022.
//

import UIKit

class WatchlistTableViewCell: UITableViewCell {
    static let identifier = "WatchlistTableViewCell"
    static let preferredHeight: CGFloat = 60
    
    struct ViewModel{
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
    }
    
    // MARK: - Cell Components
    // Symbol Label
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    // Company Label
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    // MiniChart View
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.backgroundColor = .link
        return chart
    }()
    
    // Price Label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    // Change in Price Label
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(symbolLabel)
        addSubview(companyLabel)
        addSubview(priceLabel)
        addSubview(changeLabel)
        addSubview(miniChartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        symbolLabel.sizeToFit()
        companyLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        
        let yStart: CGFloat = (contentView.frame.height - symbolLabel.frame.height - companyLabel.frame.height) / 2
        symbolLabel.frame = CGRect(x: separatorInset.left,
                                   y: yStart,
                                   width: symbolLabel.frame.width,
                                   height: symbolLabel.frame.height)
        
        companyLabel.frame = CGRect(x: separatorInset.left,
                                    y: symbolLabel.frame.origin.y + symbolLabel.frame.height,
                                    width: symbolLabel.frame.width,
                                    height: symbolLabel.frame.height)
        
        priceLabel.frame = CGRect(x: contentView.frame.width - 10 - priceLabel.frame.width,
                                    y: 0,
                                    width: priceLabel.frame.width,
                                    height: priceLabel.frame.height)
        
        changeLabel.frame = CGRect(x: contentView.frame.width - 10 - changeLabel.frame.width,
                                    y: priceLabel.frame.origin.y + priceLabel.frame.height,
                                    width: changeLabel.frame.width,
                                    height: changeLabel.frame.height)
        
        miniChartView.frame = CGRect(x: priceLabel.frame.origin.x - contentView.frame.width/3 - 5,
                                     y: 6,
                                     width: contentView.frame.width / 3,
                                     height: contentView.frame.height - 12)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        companyLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        
    }
    
    public func configure(with viewModel: ViewModel){
        symbolLabel.text = viewModel.symbol
        companyLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        
    }

}
