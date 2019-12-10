//
//  InfoInput.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 28/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class InfoInput : UIToolbar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    private var infoLabelText = String()
    private var selectedTextField = UITextField()
    
    private let infoLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        return label
    }()
    
    private let addButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "addButton"), for: .normal)
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        return button
    }()
    
    private func configureView() {
        let labelItem = UIBarButtonItem(customView: infoLabel)
        let buttonItem = UIBarButtonItem(customView: addButton)
        self.items = [labelItem, buttonItem]
    }
    
    @objc private func didTapAdd() {
        selectedTextField.text = infoLabel.text
    }
    
    func assignInfoInput(textField: UITextField, info: String) {
        infoLabel.text = info
        selectedTextField = textField
    }
    
    
    
    
    
    
}
