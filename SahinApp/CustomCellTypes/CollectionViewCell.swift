//
//  CollectionViewCell.swift
//  SahinApp
//
//  Created by Sahin on 11/02/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {

    // I create a custom cell with an imageview for my collection view cell
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.image = UIImage(named: "freezer")
        iv.layer.cornerRadius = 16
        return iv
    }()
    
    // Gradient overlay for better text readability
    let gradientOverlay: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        return gradient
    }()
    
    // Title label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.shadowColor = UIColor.black.withAlphaComponent(0.3)
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()

    //computed variable where i set the imageview to the backgroundimage in my customdata struct.
    var data: CustomData? {
        didSet {
            guard let data = data else { return }
            imageView.image = data.backgroundImage
            titleLabel.text = data.title.capitalized
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        // Add shadow to cell
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 12
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.masksToBounds = false

        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientOverlay.frame = imageView.bounds
        imageView.layer.insertSublayer(gradientOverlay, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
