//
//  NewEventViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol NewEventViewControllerDelegate: class {
    func newEventVCDidTapNext(controller: NewEventViewController)
    func newEventVCDdidTapProfile(controller: NewEventViewController)
    
    // For TestCase
    func eventDescriptionVCDidTapFinish(controller: NewEventViewController)
}

class NewEventViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dinnerNameTextField: UITextField!
    @IBOutlet weak var hostNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var testButton: UIButton!
    
    weak var delegate: NewEventViewControllerDelegate?
    
    let datePicker = DatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .newEventVC
        setupUI()
        let textFields = [dinnerNameTextField, hostNameTextField, locationTextField, dateTextField]
        textFields.forEach { textField in
            textField!.delegate = self
        }
    }
    
    func setupUI() {
        errorLabel.isHidden = true
        checkForExistingEvent()
        progressView.progressTintColor = Colors.newGradientRed
        progressView.trackTintColor = .white
        progressView.progress = 0
        progressView.setProgress(1/5, animated: true)
        dinnerNameTextField.setLeftView(image: UIImage(named: "titleIcon2")!)
        locationTextField.setLeftView(image: UIImage(named: "locationIcon")!)
        hostNameTextField.setLeftView(image: UIImage(named: "hostIcon")!)
        dateTextField.setLeftView(image: UIImage(named: "dateIcon")!)
        
        
        
        if !defaults.address.isEmpty {
            let addressInput = InfoInput(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 40)))
            addressInput.assignInfoInput(textField: locationTextField, info: defaults.address)
            locationTextField.inputAccessoryView = addressInput
        }
        if !defaults.username.isEmpty {
            let hostInput = InfoInput(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 40)))
                hostInput.assignInfoInput(textField: hostNameTextField, info: defaults.username)
                hostNameTextField.inputAccessoryView = hostInput
        }
    }
    
    @IBAction func DidTapTestButton(_ sender: Any) {
        
        // Initiate TestCase
        let event = testCase.createCaseOne()
        Event.shared.dinnerName = event.dinnerName
        Event.shared.hostName = event.hostName
        Event.shared.eventDescription = event.eventDescription
        Event.shared.dinnerLocation = event.dinnerLocation
        Event.shared.dateTimestamp = event.dateTimestamp
        // Remove Child Controller
        
        delegate?.eventDescriptionVCDidTapFinish(controller: self)
        
        print(Event.shared)
        // Go to Review VC
    }
    
    func presentDatePicker() {
      
//        let toolbar = UIToolbar(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.width, height: CGFloat(44))))
//        toolbar.sizeToFit()
//        toolbar.tintColor = Colors.customPink
//        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didTapDonePicker))
//        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelPicker))
//        toolbar.setItems([cancelButton,space,doneButton], animated: false)
//
//        dateTextField.inputAccessoryView = toolbar
        datePicker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)
        dateTextField.inputView = datePicker

    }
    
    @objc func didSelectDate() {
          let formatter = DateFormatter()
          formatter.dateFormat = "MMM d, h:mm a"
          dateTextField.text = formatter.string(from: datePicker.date)
      }
    
//    @objc func didTapDonePicker() {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM d, h:mm a"
//        dateTextField.text = formatter.string(from: datePicker.date)
//        dateTextField.endEditing(true)
//    }
//
//    @objc func didTapCancelPicker() {
//        dateTextField.endEditing(true)
//    }
    
    private func checkForExistingEvent() {
        dinnerNameTextField.text = Event.shared.dinnerName
        hostNameTextField.text = Event.shared.hostName
        locationTextField.text = Event.shared.dinnerLocation
        if !Event.shared.dateTimestamp.isZero {
            dateTextField.text = Event.shared.dinnerDate
        }
    }
    
     private func allFieldsAreFilled() -> Bool {
        guard let host = hostNameTextField.text, let dinner = dinnerNameTextField.text, let location = locationTextField.text, let date = dateTextField.text else {
            return false
        }
        if !host.isEmpty && !dinner.isEmpty && !location.isEmpty && !date.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    
    @IBAction func didTapNext(_ sender: UIButton) {
        
        if !allFieldsAreFilled() {
            dinnerNameTextField.animateEmpty()
            hostNameTextField.animateEmpty()
            locationTextField.animateEmpty()
            dateTextField.animateEmpty()
            errorLabel.isHidden = false
            view.endEditing(true)
            print("fields not filled")
        } else {
            guard let host = hostNameTextField.text, let dinner = dinnerNameTextField.text, let location = locationTextField.text else { return }
            Event.shared.hostName = host
            Event.shared.dinnerName = dinner
            Event.shared.dinnerLocation = location
            Event.shared.dateTimestamp = datePicker.date.timeIntervalSince1970
            animatedTextFields()
            
        }
    }
    
    @IBAction func didTapProfileButton(_ sender: UIButton) {
        delegate?.newEventVCDdidTapProfile(controller: self)
    }
    
    private func animatedTextFields() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.dinnerNameTextField.transform = CGAffineTransform(translationX: 0, y: -10)
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.dinnerNameTextField.alpha = 0
                self.dinnerNameTextField.transform = self.dinnerNameTextField.transform.translatedBy(x: 200, y: 0)
                
                UIView.transition(with: self.titleLabel, duration: 2, options: .transitionCrossDissolve, animations: {
                    self.titleLabel.textColor = Colors.newGradientRed
                }, completion: nil)
            })
        }
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.hostNameTextField.transform = CGAffineTransform(translationX: 0, y: -10)
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.hostNameTextField.alpha = 0
                self.hostNameTextField.transform = self.hostNameTextField.transform.translatedBy(x: 200, y: 0)
            })
        }
        UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.locationTextField.transform = CGAffineTransform(translationX: 0, y: -10)
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.locationTextField.alpha = 0
                self.locationTextField.transform = self.locationTextField.transform.translatedBy(x: 200, y: 0)
            })
        }
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.dateTextField.transform = CGAffineTransform(translationX: 0, y: -10)
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.dateTextField.alpha = 0
                self.dateTextField.transform = self.dateTextField.transform.translatedBy(x: 200, y: 0)
            }, completion: { (_) in
                self.delegate!.newEventVCDidTapNext(controller: self)
            })
}
        
    }
    
    
    
}

extension NewEventViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == dateTextField {
            presentDatePicker()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
              case dinnerNameTextField:
                  hostNameTextField.becomeFirstResponder()
              case hostNameTextField:
                  locationTextField.becomeFirstResponder()
              case locationTextField:
                  dateTextField.becomeFirstResponder()
              case dateTextField:
                    textField.resignFirstResponder()
              default:
                  break
              }
        textField.resignFirstResponder()
        return true
    }
    
   func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case dinnerNameTextField:
            
            Event.shared.dinnerName = textField.text ?? ""
        case hostNameTextField:
            Event.shared.hostName = textField.text ?? ""
        case locationTextField:
            Event.shared.dinnerLocation = textField.text ?? ""
        case dateTextField:
            Event.shared.dateTimestamp = datePicker.date.timeIntervalSince1970
        default:
            break
        }
    }
    
    
    
}


