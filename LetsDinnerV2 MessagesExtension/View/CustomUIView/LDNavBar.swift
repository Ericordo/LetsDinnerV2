//
//  LDNavBar.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SnapKit

class LDNavBar : UIView {
    
    let previousButton : LDNavButton = {
        let button = LDNavButton()
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    let nextButton : LDNavButton = {
        let button = LDNavButton()
        button.setTitle(LabelStrings.next, for: .normal)
        button.contentHorizontalAlignment = .trailing
        return button
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor.textLabel
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(previousButton)
        addSubview(nextButton)
        addSubview(titleLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        let offset = StepStatus.currentStep == .registrationVC ? 17 : 9
        previousButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(offset)
            make.centerY.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-17)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(previousButton.snp.trailing)
            make.trailing.equalTo(nextButton.snp.leading)
        }
    }
}
