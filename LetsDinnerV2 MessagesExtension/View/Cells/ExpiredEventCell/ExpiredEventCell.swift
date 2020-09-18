//
//  ExpiredEventCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by DiMa on 10/02/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class ExpiredEventCell: UITableViewCell {
    
    static let reuseID = "ExpiredEventCell"
    
    private let infoLabel = LDLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        if Event.shared.eventIsExpired {
            infoLabel.configureText(title: LabelStrings.pastEventTitle,
                                    text: LabelStrings.pastEventDescription)
        } else if Event.shared.isCancelled {
            infoLabel.configureText(title: LabelStrings.canceledEventTitle,
                                    text: LabelStrings.canceledEventDescription)
        }
        self.contentView.addSubview(infoLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-40)
        }
    }
}

