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
        func registrationVCDidTapCancelButton(controller: RegistrationViewController)
}

class RegistrationViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var addPicButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    weak var delegate: RegistrationViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        nameTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
       
        if !defaults.username.isEmpty {
            nameTextField.text = defaults.username
        }
        errorLabel.isHidden = true
        titleLabel.text = LabelStrings.getStarted
        
        userPic.setImage(string: defaults.username.initials, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 40, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
        
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
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        delegate?.registrationVCDidTapCancelButton(controller: self)
    }
    
    
    @IBAction func didTapAddPic(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Calm down, not implemented yet", message: "Soon baby", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I'm sorry, you are the best Eric", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        userPic.setImage(string: text, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 40, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
}
