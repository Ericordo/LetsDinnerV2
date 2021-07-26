//
//  AnswerAcceptedCell.swift
//  LetsDinnerV2
//
//  Created by Alex Cheung on 18/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol AnswerAcceptedCellDelegate: AnyObject {
    func showUpdateAcceptedStatusAlert()
}

class AnswerAcceptedCell: UITableViewCell {
    
    static let reuseID = "AnswerAcceptedCell"
    
    private lazy var acceptButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .secondaryButtonBackground
        button.layer.cornerRadius = 21
        button.clipsToBounds = true
        button.setImage(Images.checkmark, for: .normal)
        button.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)
        return button
    }()
    
    private let acceptLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.acceptedLabel
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .secondaryTextLabel
        return label
    }()
    
    weak var delegate: AnswerAcceptedCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapAccept() {
        delegate?.showUpdateAcceptedStatusAlert()
    }
    
     private func setupUI() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        self.contentView.addSubview(acceptButton)
        self.contentView.addSubview(acceptLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        acceptButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.height.width.equalTo(42)
            make.centerY.equalToSuperview()
        }
        
        acceptLabel.snp.makeConstraints { make in
            make.centerY.equalTo(acceptButton.snp.centerY)
            make.leading.equalTo(acceptButton.snp.trailing).offset(10)
        }
    }
}
