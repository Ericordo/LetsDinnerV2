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
        #warning("This locale may be responsible for the bug of different date in bubble and viewcontroller")
        locale = Locale(identifier: "en_GB")
        minimumDate = Date()
        tintColor = UIColor.textLabel
    }
}
