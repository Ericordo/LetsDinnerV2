//
//  CreateRecipeCookingStepTableViewCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 23/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class CreateRecipeCookingStepCell: UITableViewCell {
    
    static let reuseID = "CreateRecipeCookingStepCell"
    
    private let cookingStepLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .textLabel
        //        label.sizeToFit()
        return label
    }()
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(stepDetail: String, stepNumber: Int) {
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(string: String(stepNumber) + ". ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]))
        attributedString.append(NSAttributedString(string: stepDetail, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]))
        cookingStepLabel.attributedText = attributedString
    }
    
    private func setupUI() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        self.contentView.addSubview(cookingStepLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        cookingStepLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().offset(-13)
            make.trailing.equalToSuperview().offset(-10)
//            make.height.greaterThanOrEqualTo(44)
        }
    }
}

