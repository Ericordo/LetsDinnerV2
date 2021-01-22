//
//  LDListItemAdditionView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 18/08/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDListItemAdditionView: UIView {

    let addButton : UIButton = {
        let button = UIButton()
        button.setImage(Images.addButton, for: .normal)
        return button
    }()
    
    let textField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.textColor = .textLabel
        textField.font = .systemFont(ofSize: 17)
        textField.tintColor = .activeButton
        textField.returnKeyType = .done
        return textField
    }()
    
    let secondaryTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.textColor = .textLabel
        textField.font = .systemFont(ofSize: 13, weight: .semibold)
        textField.tintColor = .activeButton
        textField.placeholder = LabelStrings.amountPlaceholder
        textField.returnKeyType = .done
        return textField
    }()
    
    private let separator : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    private let section : CreateRecipeSections

    init(section: CreateRecipeSections) {
        self.section = section
        self.textField.placeholder = section.placeholder
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .backgroundColor
        addSubview(separator)
        addSubview(addButton)
        if self.section == .ingredient {
            addSubview(secondaryTextField)
        }
        addSubview(textField)
        addConstraints()
    }
    
    private func addConstraints() {
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(2)
            make.width.height.equalTo(22)
        }
        
        if self.section == .ingredient {
            secondaryTextField.snp.makeConstraints { make in
                make.height.equalTo(22)
                make.leading.equalTo(addButton.snp.trailing).offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.bottom.equalTo(separator.snp.top)
            }
            
            textField.snp.makeConstraints { make in
                make.leading.equalTo(addButton.snp.trailing).offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.top.equalToSuperview()
                make.bottom.equalTo(secondaryTextField.snp.top)
            }
        } else {
            textField.snp.makeConstraints { make in
                make.leading.equalTo(addButton.snp.trailing).offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.top.equalToSuperview()
                make.bottom.equalTo(separator.snp.top)
            }
        }
    }
}
