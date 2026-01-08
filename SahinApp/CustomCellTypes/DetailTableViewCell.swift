//
//  DetailTableViewCell.swift
//  SahinApp
//
//  Created by Sahin on 11/02/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import Foundation
import UIKit

class DetailTableViewCell: UITableViewCell {

    //this custom cell is for the tableview that i display once i click into a specific storage, i have an identifier called customCell which is used in my tableviewcontroller to know which cell to initialise with.
    
    static var customCell = "cell"
    
    public var itemLabel: UILabel = {
        let label1 = UILabel()
        label1.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label1.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label1.textColor = .black
        label1.numberOfLines = 0
        label1.alpha = 1
        return label1
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(itemLabel)

        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0
        contentView.layer.masksToBounds = false
        
        // Add shadow
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOpacity = 1.0
        
        // Add padding
        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        itemLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        itemLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        itemLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        itemLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -20).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
