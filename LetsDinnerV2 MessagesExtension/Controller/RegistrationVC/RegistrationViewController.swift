//
//  RegistrationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol RegistrationViewControllerDelegate : class {
    
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
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        saveButton.layer.cornerRadius = 8.0
        saveButton.layer.masksToBounds = true
        saveButton.setGradient(colorOne: Colors.gradientRed, colorTwo: Colors.gradientPink)
        
        
    }



    
    @IBAction func didTapSave(_ sender: UIButton) {
    }
    
}
