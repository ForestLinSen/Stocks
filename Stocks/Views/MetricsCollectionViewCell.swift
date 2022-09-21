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
        contentView.addSubview(valueLabel)
        contentView.addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        valueLabel.sizeToFit()
        nameLabel.sizeToFit()
        
        nameLabel.frame = CGRect(x: 3, y: 0,
                                 width: nameLabel.frame.width, height: contentView.frame.height)
        valueLabel.frame = CGRect(x: nameLabel.frame.width + nameLabel.frame.origin.x + 3, y: 0,
                                  width: valueLabel.frame.width, height: contentView.frame.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }
    
    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name
        valueLabel.text = viewModel.value
    }
    
    
}
