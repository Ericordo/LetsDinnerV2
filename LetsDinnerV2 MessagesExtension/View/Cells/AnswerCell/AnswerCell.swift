//
//  AnswerCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol AnswerCellDelegate: class {
    func addToCalendarAlert()
    func declineEventAlert()
    func declineInvitation() 
}

class AnswerCell: UITableViewCell {
    
    static let reuseID = "AnswerCell"
    
    private lazy var acceptButton : UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.secondaryButtonBackground
        button.setTitleColor(.buttonTextBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setImage(Images.checkmark, for: .normal)
        button.setTitle(" \(ButtonTitle.accept)", for: .normal)
        button.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)
        return button
    }()
    
    private lazy var declineButton : UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.secondaryButtonBackground
        button.setTitleColor(.buttonTextRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setImage(Images.warning, for: .normal)
        button.setTitle(" \(ButtonTitle.decline)", for: .normal)
        button.addTarget(self, action: #selector(didTapDecline), for: .touchUpInside)
        return button
    }()
    
    private let acceptedLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.acceptedLabel
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .secondaryTextLabel
        label.isHidden = true
        return label
    }()
    
    private let declinedLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.declinedLabel
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .secondaryTextLabel
        label.isHidden = true
        return label
    }()
    
    private let invitationLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.invitationText
        label.font = .systemFont(ofSize: 17)
        label.textColor = .textLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private let stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 31
        sv.distribution = .fillEqually
        sv.alignment = .fill
        return sv
    }()
    
    private let separatorLine : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    weak var delegate: AnswerCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .backgroundColor
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(animateDecline),
                                               name: Notification.Name(rawValue: "TappedDecline"),
                                               object: nil)
        self.contentView.addSubview(invitationLabel)
        self.contentView.addSubview(stackView)
        stackView.addArrangedSubview(declineButton)
        stackView.addArrangedSubview(declinedLabel)
        stackView.addArrangedSubview(acceptButton)
        stackView.addArrangedSubview(acceptedLabel)
        self.contentView.addSubview(separatorLine)
        addConstraints()
    }
    
    private func addConstraints() {
        invitationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.height.equalTo(42)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalTo(invitationLabel.snp.bottom).offset(12)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    @objc private func didTapAccept() {
        self.acceptButton.setTitle("", for: .normal)
        self.declineButton.isHidden = true
        stackView.distribution = .fillProportionally
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.stackView.spacing = 10
            self.acceptButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
            self.acceptedLabel.isHidden = false
            self.acceptButton.layer.cornerRadius = self.acceptButton.frame.size.height / 2
        }) { (_) in
            self.delegate?.addToCalendarAlert()
        }
    }
    
    @objc private func didTapDecline() {
        delegate?.declineEventAlert()
    }
    
    @objc private func animateDecline() {
        self.declineButton.setTitle("", for: .normal)
        self.acceptButton.isHidden = true
        stackView.distribution = .fillProportionally
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.stackView.spacing = 10
            self.declineButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
            self.declinedLabel.isHidden = false
            self.declineButton.layer.cornerRadius = self.acceptButton.frame.size.height / 2
        }) { (_) in
            self.delegate?.declineInvitation()
        }
    }
}
