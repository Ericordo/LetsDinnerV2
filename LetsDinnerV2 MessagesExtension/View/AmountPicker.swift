//
//  AmountPicker.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 08/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol ToolbarAmountPickerDelegate: class {
    func didTapDone()
    func didTapCancel()
}

class AmountPicker: UIPickerView {
    
    let toolbar = UIToolbar()
    
    let units = ["", "mL", "L", "g", "kg", "cup", "handfull", "tbsp", "tsp", "pinch"]
    
    
    weak var toolbarDelegate: ToolbarAmountPickerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPicker() {
        backgroundColor = .backgroundColor
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .textLabel
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
    
    }
    
    @objc func doneTapped() {
        self.toolbarDelegate?.didTapDone()
    }
    
    @objc func cancelTapped() {
        self.toolbarDelegate?.didTapCancel()
    }
    
}
