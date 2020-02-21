//
//  RegistrationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

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
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var metricImageView: UIImageView!
    @IBOutlet weak var imperialImageView: UIImageView!
    @IBOutlet weak var metricView: UIView!
    @IBOutlet weak var imperialView: UIView!
    
    weak var delegate: RegistrationViewControllerDelegate?
    
    private let picturePicker = UIImagePickerController()
    private let locationManager = CLLocationManager()
    private var didFindLocation = false
    
    private var profileImage: UIImage?
    
    var previousStep: StepTracking?
    
    private var imageState : ImageState = .addPic
    
    private let topViewMinHeight: CGFloat = 90
    private let topViewMaxHeight: CGFloat = 170
    
    private var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if StepStatus.currentStep == .initialVC || StepStatus.currentStep == .newEventVC {
            StepStatus.currentStep = .registrationVC
        }
        
        let tapGestureToHideKeyboard = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGestureToHideKeyboard)
        
        setupUI()

        picturePicker.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        addressTextField.delegate = self
        scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    private func setupUI() {
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        if !defaults.username.isEmpty {
            let usernameArray = defaults.username.split(separator: " ")
            firstNameTextField.text = String(usernameArray.first!)
            lastNameTextField.text = String(usernameArray.last!)
        }
        
        if !defaults.address.isEmpty {
            addressTextField.text = defaults.address
            locationButton.isHidden = true
        }
        
        
        let tapGestureMetric = UITapGestureRecognizer(target: self, action: #selector(setupMetricSystem))
        let tapGestureImperial = UITapGestureRecognizer(target: self, action: #selector(setupImperialSystem))
        imperialView.addGestureRecognizer(tapGestureImperial)
        metricView.addGestureRecognizer(tapGestureMetric)
        
        errorLabel.isHidden = true

        userPic.layer.cornerRadius = userPic.frame.height / 2
        userPic.layer.masksToBounds = true

        if let imageURL = URL(string: defaults.profilePicUrl) {
            userPic.kf.indicatorType = .activity
            addPicButton.isHidden = true
            userPic.kf.setImage(with: imageURL, placeholder: UIImage(named: "profilePlaceholder")) { result in
                switch result {
                case .success:
                    self.addPicButton.setTitle("Edit image", for: .normal)
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
            userPic.image = UIImage(named: "profilePlaceholder")
            addPicButton.setTitle("Add image", for: .normal)
            imageState = .addPic
        }
        
        if defaults.measurementSystem == "imperial" {
            setupImperialSystem()
        } else {
            setupMetricSystem()
        }
    }
    
    @objc private func setupImperialSystem() {
        imperialImageView.image = UIImage(named: "checkmark")
        metricImageView.image = nil
        defaults.measurementSystem = "imperial"
    }
    
    @objc private func setupMetricSystem() {
        imperialImageView.image = nil
        metricImageView.image = UIImage(named: "checkmark")
        defaults.measurementSystem = "metric"
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
            let alert = UIAlertController(title: "My image", message: "", preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = addPicButton
            alert.popoverPresentationController?.sourceRect = addPicButton.bounds
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
    
    @IBAction func tapLocationButton(_ sender: Any) {
        findCurrentLocation()
    }
    
    private func findCurrentLocation() {
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()

        // For use in foreground
//        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
//            guard didFindLocation == false else { return }
            locationManager.startUpdatingLocation()
        }
    }
    
    private func presentPicker() {
        picturePicker.popoverPresentationController?.sourceView = addPicButton
        picturePicker.popoverPresentationController?.sourceRect = addPicButton.bounds
        picturePicker.sourceType = .photoLibrary
        picturePicker.allowsEditing = true
        present(picturePicker, animated: true, completion: nil)
    }
    
    private func checkUsername() {
        if !defaults.username.isEmpty {
            userPic.setImage(string: defaults.username.initials, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 50, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
            addPicButton.setTitle("Add image", for: .normal)
        } else {
            userPic.image = UIImage(named: "profilePlaceholder")
            addPicButton.setTitle("Add image", for: .normal)
        }
        imageState = .addPic
    }
    
    private func updateInitials() {
        if imageState == .addPic && headerViewHeightConstraint.constant == topViewMaxHeight {
            if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text {
                
                if !firstName.isEmpty {
                    userPic.setImage(string: firstName + " " + lastName, color: .lightGray, circular: true, stroke: true, strokeColor: Colors.customGray, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 50, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                } else {
                    userPic.image = UIImage(named: "profilePlaceholder")
                    
                }
            }
        }
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
                if let previousStep = previousStep {
                    delegate?.registrationVCDidTapSaveButton(controller: self, previousStep: previousStep)
                }
            }
        }
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateInitials()
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if addressTextField.text!.count > 20 {
            locationButton.isHidden = true
        } else {
            locationButton.isHidden = false
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if addressTextField.isEditing {
            locationButton.isHidden = false
        }

        return true
    }
}

extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        profileImage = imageOriginal
        userPic.image = imageOriginal
        
        guard let imageEdited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        profileImage = imageEdited
        userPic.image = imageEdited
        
        imageState = .deleteOrModifyPic
        addPicButton.setTitle("Modify image", for: .normal)
       
        picturePicker.dismiss(animated: true, completion: nil)
    }
}

extension RegistrationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        userPic.layer.cornerRadius = userPic.frame.height / 2
        if yOffset < -topViewMaxHeight {
            headerViewHeightConstraint.constant = self.topViewMaxHeight
            updateInitials()
        } else if yOffset < -topViewMinHeight {
            headerViewHeightConstraint.constant = yOffset * -1
        } else {
            headerViewHeightConstraint.constant = topViewMinHeight
        }
        
        if headerViewHeightConstraint.constant == topViewMaxHeight {
            addPicButton.alpha = 1
        } else {
            addPicButton.alpha = 0
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        var rectangle = self.view.frame
        rectangle.size.height -= keyboardFrame.height
        
        if let activeField = activeField {
            if !rectangle.contains(activeField.frame.origin) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
}

extension RegistrationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Prevent didUpdateLocations run multiple time
        locationManager.stopUpdatingLocation()
//        locationManager.delegate = nil
        
        // Get User Location
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: locValue.latitude, longitude:locValue.longitude)) { (places, error) in
            if error == nil {
                if let place = places {
                    let location = place[0]
                    
                    if let name = location.name,
                        var country = location.country,
                        var adminstrationArea = location.administrativeArea,
                        var subArea = location.subAdministrativeArea {
                        
                        subArea = " " + subArea
                        adminstrationArea = " " + adminstrationArea
                        country = " " + country
                        
                        self.addressTextField.text = name + subArea + adminstrationArea + country
                        self.locationButton.isHidden = true
//                        print(name + subArea + adminstrationArea + country)
                    }
                }
            } else {
                print("Location cannot be found")
            }
        }
    }
}

