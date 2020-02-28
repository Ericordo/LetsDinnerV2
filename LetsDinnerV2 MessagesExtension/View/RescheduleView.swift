//
//  RescheduleView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 27/01/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class RescheduleView: UIView {
    
    let datePicker : UIDatePicker = {
        let dp = DatePicker()
        dp.minimumDate = Date()
        dp.date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
        return dp
    }()
    
//    let titleLabel : UILabel = {
//        let label = UILabel()
//        label.text = LabelStrings.selectNewDate
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//        label.textColor = UIColor.textLabel
//        return label
//    }()
//
    let titleLabel : LDLabel = {
        let label = LDLabel(title: LabelStrings.rescheduleTitle, text: LabelStrings.rescheduleText)
        return label
    }()
    
    let cancelButton : UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = Colors.paleGray
        return button
    }()
    
    let updateButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 253, height: 50))
        button.layer.masksToBounds = true
        button.alpha = 0.5
        button.layer.cornerRadius = 12
        button.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.setTitle(LabelStrings.update, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func resetPicker() {
        datePicker.date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
        updateButton.alpha = 0.5
    }
    
    
    private func setupView() {
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.backgroundColor = .backgroundColor
        self.addSubview(updateButton)
        self.addSubview(titleLabel)
        self.addSubview(datePicker)
        
        addConstraints()
    }
    
    private func addConstraints() {
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            updateButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
            updateButton.widthAnchor.constraint(equalToConstant: 253),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            updateButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            datePicker.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 200),
//            datePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            datePicker.bottomAnchor.constraint(equalTo: updateButton.topAnchor, constant: -5),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 75),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
//            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: datePicker.topAnchor, constant: -5)
            
            
            
        ])
        
    }
}

