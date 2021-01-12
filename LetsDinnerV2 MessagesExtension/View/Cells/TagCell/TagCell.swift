//
//  TagCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 10/01/2021.
//  Copyright © 2021 Eric Ordonneau. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    static let reuseID = "TagCell"
    
    private let containerView = UIView()
    
    let deleteButton : UIButton = {
        let button = UIButton()
        button.setImage(Images.statusDeclined, for: .normal)
        return button
    }()
    
    private let tagLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(tag: String, deletingAllowed: Bool) {
        tagLabel.text = tag
        if deletingAllowed {
            deleteButton.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(4)
                make.width.equalTo(22)
            }
        } else {
            deleteButton.snp.updateConstraints { make in
                make.leading.equalToSuperview()
                make.width.equalTo(0)
            }
        }
    }
    
    private func setupUI() {
        containerView.backgroundColor = .inactiveButton
        containerView.layer.cornerRadius = 5
        contentView.addSubview(containerView)
        containerView.addSubview(deleteButton)
        containerView.addSubview(tagLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(30)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.height.width.equalTo(22)
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
        }
        
        tagLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(deleteButton)
            make.leading.equalTo(deleteButton.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-4)
        }
    }
}
