//
//  InfoInputView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 14/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class InfoInputView : UIView {
    
    private var infoLabelText = String()
    private var selectedTextField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }

//     let infoLabel : UILabel = {
//        let label = UILabel()
//        label.backgroundColor = .clear
//        label.textAlignment = .center
//        return label
//    }()
    
    let addButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.textLabel, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17)
//        button.setImage(UIImage(named: "addButton"), for: .normal)
//        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        return button
    }()
    
    private func configureView() {
        self.backgroundColor = UIColor.keyboardBackground
        self.sizeToFit()
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func layoutSubviews() {
        addConstraints()
    }
    
    private func addConstraints() {
        addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
//        addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
//        addButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        addButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        addButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        addButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        addButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        
//        addSubview(infoLabel)
//        infoLabel.translatesAutoresizingMaskIntoConstraints = false
//        infoLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
//        infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
//        infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
//        infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
    }
    
    func assignInfoInput(textField: UITextField, info: String) {
//        infoLabel.text = info
        addButton.setTitle(info, for: .normal)
        selectedTextField = textField
    }
}
