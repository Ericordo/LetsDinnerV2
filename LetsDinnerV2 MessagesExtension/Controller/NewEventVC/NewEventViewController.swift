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
}

class NewEventViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dinnerNameTextField: UITextField!
    @IBOutlet weak var hostNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    weak var delegate: NewEventViewControllerDelegate?
    
    let datePicker = DatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let textFields = [dinnerNameTextField, hostNameTextField, locationTextField, dateTextField]
        textFields.forEach { textField in
            textField!.delegate = self
        }
        
    
    }
    
    func setupUI() {
        errorLabel.isHidden = true
        checkForExistingEvent()
    }
    
    func presentDatePicker() {
        let toolbar = UIToolbar(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.width, height: CGFloat(44))))
        toolbar.sizeToFit()
        toolbar.tintColor = Colors.customPink
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didTapDonePicker))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelPicker))
        toolbar.setItems([cancelButton,space,doneButton], animated: false)
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
    }
    
    @objc func didTapDonePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        dateTextField.text = formatter.string(from: datePicker.date)
        dateTextField.endEditing(true)
    }
    
    @objc func didTapCancelPicker() {
        dateTextField.endEditing(true)
    }
    
    func checkForExistingEvent() {
        dinnerNameTextField.text = Event.shared.dinnerName
        hostNameTextField.text = Event.shared.hostName
        locationTextField.text = Event.shared.dinnerLocation
        if !Event.shared.dateTimestamp.isZero {
            dateTextField.text = Event.shared.dinnerDate
        }
    }
    
    func allFieldsAreFilled() -> Bool {
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
            errorLabel.isHidden = false
            print("fields not filled")
        } else {
            guard let host = hostNameTextField.text, let dinner = dinnerNameTextField.text, let location = locationTextField.text else { return }
            Event.shared.hostName = host
            Event.shared.dinnerName = dinner
            Event.shared.dinnerLocation = location
            Event.shared.dateTimestamp = datePicker.date.timeIntervalSince1970
            delegate!.newEventVCDidTapNext(controller: self)
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
        textField.resignFirstResponder()
        return true
    }
    
    
    
}
