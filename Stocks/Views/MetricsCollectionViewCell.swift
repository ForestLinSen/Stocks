//
//  MetricsCollectionViewCell.swift
//  Stocks
//
//  Created by Sen Lin on 19/9/2022.
//

import UIKit

class MetricsCollectionViewCell: UICollectionViewCell {
    static let identifier = "MetricsCollectionViewCell"
    
    struct ViewModel {
        let name: String
        let value: String
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        valueLabel.sizeToFit()
        nameLabel.sizeToFit()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
}
