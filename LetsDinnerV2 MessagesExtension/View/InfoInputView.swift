//
//  InfoInputView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 14/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class InfoInputView : UIView {
    
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
    
     let infoLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    let addButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "addButton"), for: .normal)
//        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        return button
    }()
    
    private func configureView() {
        self.backgroundColor = Colors.paleGray
        self.sizeToFit()
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func layoutSubviews() {
        addConstraints()
    }
    
    private func addConstraints() {
        addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        addButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
        
    }
    
    @objc func didTapAdd() {

    }
    
    func assignInfoInput(textField: UITextField, info: String) {
        infoLabel.text = info
        selectedTextField = textField
    }
    
    
    
    
    
    
}
