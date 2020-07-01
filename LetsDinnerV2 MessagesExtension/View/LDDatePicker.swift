//
//  LDDatePicker.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDDatePicker: UIDatePicker {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPicker() {
        datePickerMode = .dateAndTime
        backgroundColor = UIColor.backgroundColor
        minimumDate = Date()
        tintColor = UIColor.textLabel
    }
}
