//
//  LDUpdateBanner.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 30/06/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDUpdateBanner: UIView {

    private let warning : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textLabel
        label.text = "Some tasks have been modified by other participants, would you like to update them?"
        return label
    }()
    
    let updateButton : PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(LabelStrings.update, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let separator : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appear() {
        UIView.animate(withDuration: 0.2) {
            self.snp.updateConstraints { make in
                make.height.equalTo(100)
            }
            self.updateButton.isHidden = false
            self.updateButton.alpha = 1
            self.superview?.layoutIfNeeded()
        }
    }
    
    func disappear() {
        UIView.animate(withDuration: 0.2) {
            self.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            self.updateButton.alpha = 0
            self.updateButton.isHidden = true
            self.superview?.layoutIfNeeded()
        }
    }
    
    private func setup() {
        addSubview(separator)
        addSubview(updateButton)
        addSubview(warning)
        self.frame.size.height = 0
        self.updateButton.isHidden = true
        self.updateButton.alpha = 0
        addConstraints()
    }
    
    private func addConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        updateButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(separator.snp.top).offset(-10)
        }
        
        warning.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-17)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalTo(updateButton.snp.top).offset(-5)
        }
    }
}

