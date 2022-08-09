//
//  NewsStoryTableViewCell.swift
//  Stocks
//
//  Created by Sen Lin on 7/8/2022.
//

import UIKit
import SDWebImage

class NewsStoryTableViewCell: UITableViewCell {
    static let identifier = "NewsStoryTableViewCell"
    
    static let preferredHeight: CGFloat = 140
    
    struct ViewModel{
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: URL?
        
        init(model: NewsStory){
            source = model.source
            headline = model.headline
            dateString = String.string(from: model.datetime)
            imageUrl = URL(string: model.image)
        }
    }
    
    // MARK: Private Components
    // Source, Headline, Date, Image
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = nil
        addSubview(sourceLabel)
        addSubview(headlineLabel)
        addSubview(dateLabel)
        addSubview(storyImageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = contentView.frame.height - 18
        storyImageView.frame = CGRect(x: contentView.frame.width - imageSize - 9,
                                      y: (contentView.frame.height - imageSize) / 2,
                                      width: imageSize,
                                      height: imageSize)
        
        // Layout labels
        let avaiableWidth: CGFloat = contentView.frame.width - imageSize - separatorInset.left - 10
        dateLabel.frame = CGRect(x: separatorInset.left,
                                 y: contentView.frame.height - 40,
                                 width: avaiableWidth,
                                 height: 40)
        
        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(x: separatorInset.left,
                                   y: 8,
                                   width: avaiableWidth,
                                   height: sourceLabel.frame.height)
        
        headlineLabel.frame = CGRect(x: separatorInset.left,
                                     y: sourceLabel.frame.origin.y + sourceLabel.frame.height,
                                     width: avaiableWidth,
                                     height: contentView.frame.height - sourceLabel.frame.origin.y - sourceLabel.frame.height - dateLabel.frame.height - 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    public func configure(with viewModel: ViewModel){
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        storyImageView.sd_setImage(with: viewModel.imageUrl)
    }
}
