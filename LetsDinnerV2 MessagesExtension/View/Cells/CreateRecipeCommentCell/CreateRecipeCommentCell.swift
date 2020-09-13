//
//  CreateRecipeCommentCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 12/7/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class CreateRecipeCommentCell: UITableViewCell {
    
    static let reuseID = "CreateRecipeCommentCell"
    
    private let commentLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .textLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(comment: String) {
        commentLabel.text = comment
//        commentLabel.sizeToFit()
    }
    
    private func setupUI() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        self.contentView.addSubview(commentLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        commentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
//            make.height.greaterThanOrEqualTo(44)
        }
    }
}
