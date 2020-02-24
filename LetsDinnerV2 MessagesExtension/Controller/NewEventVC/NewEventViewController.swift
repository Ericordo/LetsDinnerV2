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
    
    func eventDescriptionVCDidTapFinish(controller: NewEventViewController)
}

class NewEventViewController: UIViewController  {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dinnerNameTextField: UITextField!
    @IBOutlet weak var hostNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoInput: InfoInputView!
    @IBOutlet weak var eventInput: EventInputView!
    
    @IBOutlet weak var infoInputBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventInputBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var testButton: UIButton!
    
    weak var delegate: NewEventViewControllerDelegate?
    
    let datePicker = DatePicker()
    
    private var activeField: UITextField?
    
    private let headerViewHeight: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StepStatus.currentStep = .newEventVC
        
        setupUI()
        setupGesture()

        let textFields = [dinnerNameTextField, hostNameTextField, locationTextField, dateTextField]
        textFields.forEach { textField in
            textField!.delegate = self
            textField!.autocapitalizationType = .sentences
            textField!.autocorrectionType = .no
            
        }
        
        scrollView.delegate = self
        infoInput.addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        
        // Keyboard Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("didGoToNextStep"), object: nil, userInfo: ["step": 1])
    }
    
    func setupUI() {
        errorLabel.isHidden = true
        checkForExistingEvent()

        dinnerNameTextField.setLeftView(image: UIImage(named: "titleIcon")!)
        locationTextField.setLeftView(image: UIImage(named: "locationIcon")!)
        hostNameTextField.setLeftView(image: UIImage(named: "hostIcon")!)
        dateTextField.setLeftView(image: UIImage(named: "dateIcon")!)
                
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        eventInput.breakfastButton.addTarget(self, action: #selector(didTapEvent), for: .touchUpInside)
        eventInput.lunchButton.addTarget(self, action: #selector(didTapEvent), for: .touchUpInside)
        eventInput.dinnerButton.addTarget(self, action: #selector(didTapEvent), for: .touchUpInside)
        
        
        
//        if !defaults.address.isEmpty {
////            let addressInput = InfoInput(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 40)))
////            addressInput.assignInfoInput(textField: locationTextField, info: defaults.address)
////            locationTextField.inputAccessoryView = addressInput
//
//            let addressInput = InfoInputView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 40)))
//                       addressInput.assignInfoInput(textField: locationTextField, info: defaults.address)
//                       locationTextField.inputAccessoryView = addressInput
//
//
//
//        }
//        if !defaults.username.isEmpty {
////            let hostInput = InfoInput(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 40)))
////                hostInput.assignInfoInput(textField: hostNameTextField, info: defaults.username)
////                hostNameTextField.inputAccessoryView = hostInput
//
//            let hostInput = InfoInputView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 40)))
//            hostInput.assignInfoInput(textField: hostNameTextField, info: defaults.username)
//            hostNameTextField.inputAccessoryView = hostInput
//        }
        
    }
    
    private func setupGesture() {
        self.view.addTapGestureToHideKeyboard()
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
    
    @objc func didTapEvent(sender: UIButton) {
        dinnerNameTextField.text = sender.titleLabel?.text
        eventInput.isHidden = true
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
    
    // MARK: - Button Clicked
    
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
            self.delegate!.newEventVCDidTapNext(controller: self)
            
        }
    }
    
    @IBAction func didTapProfileButton(_ sender: UIButton) {
        delegate?.newEventVCDdidTapProfile(controller: self)
    }
    
    @objc private func didTapAdd() {
        activeField?.text = infoInput.addButton.title(for: .normal)
        infoInput.isHidden = true
    }
    
    
}

// MARK: - TextFieldDelegate

extension NewEventViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
//        if textField == dateTextField {
//            presentDatePicker()
//        }
        
        
        switch textField {
        case dinnerNameTextField:
            infoInput.isHidden = true
            eventInput.isHidden = false
        case hostNameTextField:
            eventInput.isHidden = true
            if !defaults.username.isEmpty {
                infoInput.assignInfoInput(textField: hostNameTextField, info: defaults.username)
                infoInput.isHidden = false
            } else {
                infoInput.isHidden = true
            }
        case locationTextField:
            eventInput.isHidden = true
            if !defaults.address.isEmpty {
                infoInput.assignInfoInput(textField: locationTextField, info: defaults.address)
                infoInput.isHidden = false
            } else {
                infoInput.isHidden = true
            }
        case dateTextField:
            eventInput.isHidden = true
            infoInput.isHidden = true
            presentDatePicker()
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
              case dinnerNameTextField:
                  hostNameTextField.becomeFirstResponder()
              case hostNameTextField:
                  locationTextField.becomeFirstResponder()
              case dateTextField:
                textField.resignFirstResponder()
              case locationTextField:
                dateTextField.becomeFirstResponder()
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

// MARK: - ScrollViewDelegate

extension NewEventViewController: UIScrollViewDelegate {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        scrollView.contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        var rectangle = self.view.frame
        rectangle.size.height -= keyboardFrame.height
        
        if let activeField = activeField {
            if !rectangle.contains(activeField.frame.origin) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
        if activeField == locationTextField || activeField == hostNameTextField {
            
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 1) {
                self.infoInputBottomConstraint.constant = keyboardFrame.height
                
                // Temp solve:
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.infoInputBottomConstraint.constant += 20
                }
                
                self.view.layoutIfNeeded()
            }
        } else if activeField == dinnerNameTextField {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 1) {
                self.eventInputBottomConstraint.constant = keyboardFrame.height
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.eventInputBottomConstraint.constant += 20
                }
                
                self.view.layoutIfNeeded()
            }
        }
        
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1) {

            self.infoInputBottomConstraint.constant = -51
            self.eventInputBottomConstraint.constant = -51

            self.view.layoutIfNeeded()
        }
    }
    
}





