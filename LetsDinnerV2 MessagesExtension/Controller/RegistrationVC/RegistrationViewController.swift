//
//  RegistrationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol RegistrationViewControllerDelegate : class {
        func registrationVCDidTapSaveButton(controller: RegistrationViewController, previousStep: StepTracking)
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
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    weak var delegate: RegistrationViewControllerDelegate?
    
    let picturePicker = UIImagePickerController()
    
    var profileImage: UIImage?
    
    var previousStep: StepTracking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if StepStatus.currentStep == .initialVC || StepStatus.currentStep == .newEventVC {
            StepStatus.currentStep = .registrationVC
        }
        
        setupUI()
        nameTextField.delegate = self
        picturePicker.delegate = self
        
     
    }
    
    func setupUI() {
       
        if !defaults.username.isEmpty {
            nameTextField.text = defaults.username
        }
        errorLabel.isHidden = true
        titleLabel.text = LabelStrings.getStarted
        
        userPic.layer.cornerRadius = userPic.frame.height / 2
        userPic.layer.masksToBounds = true
        userPic.layer.borderWidth = 2.0
        userPic.layer.borderColor = Colors.customPink.cgColor
        
        if let imageURL = URL(string: defaults.profilePicUrl) {
            userPic.kf.setImage(with: imageURL)
        } else {
            userPic.setImage(string: defaults.username.initials, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 40, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
            deleteButton.isHidden = true
        }
        
        
    }



    @IBAction func didTapSave(_ sender: UIButton) {
        Event.shared.saveUserPicToFirebase(profileImage) { url in
            Event.shared.currentUser?.profilePicUrl = url
            if let profilePicUrl = url {
                defaults.profilePicUrl = profilePicUrl
            }
            
        }
        
        guard let text = nameTextField.text else { return }
        switch text.isEmpty {
        case true:
            errorLabel.isHidden = false
        case false:
            defaults.username = text
            delegate?.registrationVCDidTapSaveButton(controller: self, previousStep: previousStep!)
        }
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        delegate?.registrationVCDidTapCancelButton(controller: self)
    }
    
    
    @IBAction func didTapAddPic(_ sender: UIButton) {
        
        picturePicker.sourceType = .photoLibrary
        picturePicker.allowsEditing = true
        present(picturePicker, animated: true, completion: nil)
                                                
        
        
    }
    
    @IBAction func didTapDeletePic(_ sender: UIButton) {
        let alert = UIAlertController(title: "Do you want to delete your picture?", message: "", preferredStyle: .alert)
        let delete = UIAlertAction(title: "Yes", style: .destructive) { action in
            defaults.profilePicUrl = ""
            self.userPic.setImage(string: defaults.username.initials, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 40, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
            self.deleteButton.isHidden = true
        }
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if deleteButton.isHidden {
        userPic.setImage(string: text, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 40, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
}

extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let imageEdited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        profileImage = imageEdited
        userPic.image = imageEdited
        
        guard let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        profileImage = imageOriginal
        userPic.image = imageOriginal
       
        deleteButton.isHidden = false
        picturePicker.dismiss(animated: true, completion: nil)
    }
}
