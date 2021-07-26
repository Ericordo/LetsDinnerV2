//
//  CancelCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 26/01/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol CancelCellDelegate: AnyObject {
    func postponeEvent()
    func cancelEvent()
}

class CancelCell: UITableViewCell {
    
    static let reuseID = "CancelCell"
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.cancelOrReschedule
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryTextLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.spacing = 15
        return sv
    }()
    
    private lazy var postponeButton : UIButton = {
        let button = UIButton()
        button.setTitle(ButtonTitle.reschedule, for: .normal)
        button.backgroundColor = UIColor.secondaryButtonBackground
        button.layer.cornerRadius = 9
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.textLabel, for: .normal)
        button.addTarget(self, action: #selector(didTapPostpone), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton : UIButton = {
        let button = UIButton()
        button.setTitle(ButtonTitle.cancel, for: .normal)
        button.backgroundColor = UIColor.secondaryButtonBackground
        button.layer.cornerRadius = 9
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.textLabel, for: .normal)
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: CancelCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapPostpone() {
        delegate?.postponeEvent()
    }
    
    @objc private func didTapCancel() {
        delegate?.cancelEvent()
    }
    
    private func setupCell() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(postponeButton)
        addConstraints()
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalToSuperview().offset(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(42)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
    }
}
