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

enum ImageState {
    case addPic
    case deleteOrModifyPic
}

class RegistrationViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var addPicButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    weak var delegate: RegistrationViewControllerDelegate?
    
    let picturePicker = UIImagePickerController()
    
    var profileImage: UIImage?
    
    var previousStep: StepTracking?
    
    var imageState : ImageState = .addPic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if StepStatus.currentStep == .initialVC || StepStatus.currentStep == .newEventVC {
            StepStatus.currentStep = .registrationVC
        }
        
        setupUI()

        picturePicker.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        addressTextField.delegate = self
    }
    
    func setupUI() {
        if !defaults.username.isEmpty {
            let usernameArray = defaults.username.split(separator: " ")
            firstNameTextField.text = String(usernameArray.first!)
            lastNameTextField.text = String(usernameArray.last!)
        }
        
        if !defaults.address.isEmpty {
            addressTextField.text = defaults.address
        }
        
        errorLabel.isHidden = true

        userPic.layer.cornerRadius = userPic.frame.height / 2
        userPic.layer.masksToBounds = true

        if let imageURL = URL(string: defaults.profilePicUrl) {
            userPic.kf.indicatorType = .activity
            addPicButton.isHidden = true
            userPic.kf.setImage(with: imageURL, placeholder: UIImage(named: "profileplaceholder")) { result in
                switch result {
                case .success:
                    self.addPicButton.setTitle("Modify image", for: .normal)
                    self.imageState = .deleteOrModifyPic
                case .failure:
                    let alert = UIAlertController(title: "Error while retrieving image", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.checkUsername()
                }
                self.addPicButton.isHidden = false
                
            }
        } else if !defaults.username.isEmpty {
            userPic.setImage(string: defaults.username.initials, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 50, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
            addPicButton.setTitle("Add image", for: .normal)
            imageState = .addPic
        } else {
            userPic.image = UIImage(named: "profileplaceholder")
            addPicButton.setTitle("Add image", for: .normal)
            imageState = .addPic
        }
    }

    @IBAction func didTapSave(_ sender: UIButton) {
        view.endEditing(true)
        if let profileImage = profileImage {
            Event.shared.saveUserPicToFirebase(profileImage) { [weak self] result in
                switch result {
                case .success(let url):
                    Event.shared.currentUser?.profilePicUrl = url
                    defaults.profilePicUrl = url
                case .failure:
                    let alert = UIAlertController(title: "Error while saving image", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    self?.checkUsername()
                }
            }
        }
        
        verifyEachTextFieldAndProceed()
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        delegate?.registrationVCDidTapCancelButton(controller: self)
    }
    
    @IBAction func didTapAddPic(_ sender: UIButton) {
        switch imageState {
        case .addPic:
            presentPicker()
        case .deleteOrModifyPic:
            let alert = UIAlertController(title: "My image", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let change = UIAlertAction(title: "Change", style: .default) { action in
                self.presentPicker()
            }
            let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
                defaults.profilePicUrl = ""
                self.profileImage = nil
                self.checkUsername()
            }
            alert.addAction(cancel)
            alert.addAction(change)
            alert.addAction(delete)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func presentPicker() {
        picturePicker.sourceType = .photoLibrary
        picturePicker.allowsEditing = true
        present(picturePicker, animated: true, completion: nil)
    }
    
    private func checkUsername() {
        if !defaults.username.isEmpty {
            userPic.setImage(string: defaults.username.initials, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 50, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
            addPicButton.setTitle("Add image", for: .normal)
        } else {
            userPic.image = UIImage(named: "profileplaceholder")
            addPicButton.setTitle("Add image", for: .normal)
        }
        imageState = .addPic
    }
    
    private func verifyEachTextFieldAndProceed() {
        
        if let address = addressTextField.text {
            defaults.address = address
        }
        
        if let firstName = firstNameTextField.text {
            if firstName.isEmpty {
                firstNameTextField.shake()
                errorLabel.isHidden = false
            }
        }
        
        if let lastName = lastNameTextField.text {
            if lastName.isEmpty {
                lastNameTextField.shake()
                errorLabel.isHidden = false
            }
        }
        
        if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text {
            if !firstName.isEmpty && !lastName.isEmpty {
                defaults.username = firstName.capitalized + " " + lastName.capitalized
                errorLabel.isHidden = true
                delegate?.registrationVCDidTapSaveButton(controller: self, previousStep: previousStep!)
            }
        }
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if imageState == .addPic {
            if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text {
                if !firstName.isEmpty {
                    userPic.setImage(string: firstName + " " + lastName, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 50, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
                } else {
                    userPic.image = UIImage(named: "profileplaceholder")
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            addressTextField.becomeFirstResponder()
        case addressTextField:
            textField.resignFirstResponder()
        default:
            break
        }
        textField.resignFirstResponder()
        return true
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
        
        imageState = .deleteOrModifyPic
        addPicButton.setTitle("Modify image", for: .normal)
       
        picturePicker.dismiss(animated: true, completion: nil)
    }
}
