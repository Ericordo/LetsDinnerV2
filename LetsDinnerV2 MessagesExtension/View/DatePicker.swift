//
//  DatePicker.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class DatePicker: UIDatePicker {
    
    var toolbar = UIToolbar()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPicker() {
        datePickerMode = .dateAndTime
        backgroundColor = .white
        locale = Locale(identifier: "en_GB")
        minimumDate = Date()
        tintColor = UIColor(red:0.84, green:0.10, blue:0.25, alpha:1.0)
        
        toolbar.sizeToFit()
        toolbar.tintColor = UIColor(red:0.84, green:0.10, blue:0.25, alpha:1.0)
    }
}
