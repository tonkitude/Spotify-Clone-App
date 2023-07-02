//
//  CategoryCollectionViewCell.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 08/06/23.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "music.quarternote.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private var colors: [UIColor] = [.systemPink, .systemBlue, .systemPurple, .systemOrange, .systemGreen, .systemRed, .systemYellow, .darkGray, .systemTeal]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.frame = CGRect(x: 2.85 * contentView.width / 4, y: contentView.height / 1.95, width: contentView.height / 2 + 4, height: contentView.height / 2)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        label.text = nil
        imageView.image = UIImage(systemName: "music.quarternote.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRect(x: 10, y: 5, width: contentView.width - 20, height: contentView.height / 2)
        //imageView.frame = CGRect(x: 2.85 * contentView.width / 4, y: contentView.height / 1.95, width: contentView.height / 2 + 4, height: contentView.height / 2)
        imageView.transform = CGAffineTransform(rotationAngle: 0.4)
    }
    
    func configure(with viewModel: CategoryCollectionViewCellViewModel) {
        label.text = viewModel.title
        imageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        contentView.backgroundColor = colors.randomElement()
    }
}
