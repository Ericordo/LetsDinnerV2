//
//  InfoCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {
    
    static let reuseID = "InfoCell"
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .textLabel
        return label
    }()
    
    let infoLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.numberOfLines = 2
        return label
    }()
    
    private let stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.spacing = 5
        return sv
    }()
    
    let cellSeparator : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        self.selectionStyle = .none
        self.clipsToBounds = true
        self.backgroundColor = .backgroundColor
        self.cellSeparator.isHidden = true
        self.contentView.addSubview(cellSeparator)
        self.contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(infoLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        cellSeparator.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(0.3)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(33)
            make.trailing.equalToSuperview().offset(-33)
        }
    }
}
