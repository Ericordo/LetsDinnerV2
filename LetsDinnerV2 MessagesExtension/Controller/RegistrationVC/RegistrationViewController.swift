//
//  RegistrationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol RegistrationViewControllerDelegate : class {
        func registrationVCDidTapSaveButton(controller: RegistrationViewController)
}

class RegistrationViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: RegistrationViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        nameTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        saveButton.layer.cornerRadius = 8.0
        saveButton.layer.masksToBounds = true
        saveButton.setGradient(colorOne: Colors.gradientRed, colorTwo: Colors.gradientPink)
        if !defaults.username.isEmpty {
            nameTextField.text = defaults.username
        }
        errorLabel.isHidden = true
        
    }



    
    @IBAction func didTapSave(_ sender: UIButton) {
        guard let text = nameTextField.text else { return }
        switch text.isEmpty {
        case true:
            errorLabel.isHidden = false
        case false:
            defaults.username = text
            delegate?.registrationVCDidTapSaveButton(controller: self)
        }
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    
}
