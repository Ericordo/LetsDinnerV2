//
//  TitleCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 17/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class TitleCell: UITableViewCell {
    
    static let reuseID = "TitleCell"
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textColor = UIColor.textLabel
        label.numberOfLines = 0
        return label
    }()
    
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
        contentView.addSubview(titleLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
