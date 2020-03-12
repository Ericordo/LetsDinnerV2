//
//  ExpiredEventCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by DiMa on 10/02/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class ExpiredEventCell: UITableViewCell {
    
    private let infoLabel = LDLabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        
        self.backgroundColor = .backgroundColor

        if Event.shared.eventIsExpired {
            infoLabel.configureText(title: LabelStrings.pastEventTitle, text: LabelStrings.pastEventDescription)
        } else if Event.shared.isCancelled {
            infoLabel.configureText(title: LabelStrings.canceledEventTitle, text: LabelStrings.canceledEventDescription)
        }
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40)
        ])
    }
}

