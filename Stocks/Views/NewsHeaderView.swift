//
//  NewsHeaderView.swift
//  Stocks
//
//  Created by Sen Lin on 4/8/2022.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject{
    func newsHeaderViewDidTapButton(_ headerView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView {
    static let identifier = "NewsHeaderView"
    static let preferredHeight: CGFloat = 70
    
    weak var delegate: NewsHeaderViewDelegate?
    
    struct ViewModel{
        let title: String
        let shouldShownAddButton: Bool
    }
    
    // UI Components
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
    }()
    
    
    // MARK: - Initialization and Layout Components
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 14, y: 0, width: contentView.frame.width, height: contentView.frame.height-28)
        button.sizeToFit()
        
        button.frame = CGRect(x: contentView.frame.width - button.frame.width - 30,
                              y: button.frame.origin.y,
                              width: button.frame.width + 20,
                              height: button.frame.height + 4)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    public func configure(with viewModel: ViewModel){
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShownAddButton
    }
    
    // MARK: - Button Functions
    @objc private func didTapButton(){
        // call delegate function
        delegate?.newsHeaderViewDidTapButton(self)
    }
    
}
