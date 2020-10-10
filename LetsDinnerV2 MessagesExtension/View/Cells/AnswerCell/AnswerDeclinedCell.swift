//
//  AnswerCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol AnswerDeclinedCellDelegate: class {
    func showUpdateDeclinedStatusAlert()
}

class AnswerDeclinedCell: UITableViewCell {
    
    static let reuseID = "AnswerDeclinedCell"
    
    private lazy var declineButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .secondaryButtonBackground
        button.layer.cornerRadius = 21
        button.clipsToBounds = true
        button.setImage(Images.warning, for: .normal)
        button.addTarget(self, action: #selector(didTapDecline), for: .touchUpInside)
        return button
    }()
    
    private let declineLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.declinedLabel
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .secondaryTextLabel
        return label
    }()
    
    weak var delegate: AnswerDeclinedCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapDecline() {
        delegate?.showUpdateDeclinedStatusAlert()
    }
    
    private func setupUI() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        self.contentView.addSubview(declineButton)
        self.contentView.addSubview(declineLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        declineButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.height.width.equalTo(42)
            make.centerY.equalToSuperview()
        }
        
        declineLabel.snp.makeConstraints { make in
            make.centerY.equalTo(declineButton.snp.centerY)
            make.leading.equalTo(declineButton.snp.trailing).offset(10)
        }
    }
}
