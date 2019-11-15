//
//  EventDescriptionViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol EventDescriptionViewControllerDelegate: class {
    func eventDescriptionVCDidTapPrevious(controller: EventDescriptionViewController)
    func eventDescriptionVCDidTapFinish(controller: EventDescriptionViewController)
}

class EventDescriptionViewController: UIViewController {

    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    
    weak var delegate: EventDescriptionViewControllerDelegate?
    var placeholderLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.delegate = self
        setupUI()
        
    }

    func setupUI() {
        titleLabel.text = Event.shared.recipeTitles + "\n" + Event.shared.eventDescription
//        counterLabel.text = "500"
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        descriptionTextView.tintColor = Colors.customPink
        placeholderLabel.text = "So what’s the plan?"
        placeholderLabel.sizeToFit()
        descriptionTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = Colors.customGray
        placeholderLabel.isHidden = !descriptionTextView.text.isEmpty
        descriptionTextView.becomeFirstResponder()
        progressView.progressTintColor = Colors.newGradientRed
        progressView.trackTintColor = .white
        progressView.progress = 3/4
        progressView.setProgress(1, animated: true)
    }
    
    func checkRemainingChars() {
        let allowedChars = 500
        let charsInTextView = -descriptionTextView.text.count
        let remainingChars = allowedChars + charsInTextView
        counterLabel.text = String(remainingChars)
    }

    @IBAction func didTapPrevious(_ sender: UIButton) {
         delegate?.eventDescriptionVCDidTapPrevious(controller: self)
    }
    
    @IBAction func didTapFinish(_ sender: UIButton) {
        guard let text = descriptionTextView.text else { return }
        if text.isEmpty {
            let refreshAlert = UIAlertController(title: MessagesToDisplay.descriptionPrompt, message: "", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.descriptionTextView.becomeFirstResponder()
            }))
            present(refreshAlert, animated: true, completion: nil)
        } else {
            Event.shared.eventDescription = text
            delegate?.eventDescriptionVCDidTapFinish(controller: self)
        }
    }
 }

extension EventDescriptionViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
           descriptionTextView.resignFirstResponder()
           return true
       }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          super.touchesBegan(touches, with: event)
          self.view.endEditing(true)
      }
    
    func textViewDidChange(_ textView: UITextView) {
        checkRemainingChars()
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = descriptionTextView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        if changedText.count > 500 {
            descriptionTextView.resignFirstResponder()
        }
        return changedText.count <= 500
    }
    
    @objc func updateTextView(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            descriptionTextView.contentInset = .zero
        } else {
            descriptionTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        descriptionTextView.scrollIndicatorInsets = descriptionTextView.contentInset
        let selectedRange = descriptionTextView.selectedRange
        descriptionTextView.scrollRangeToVisible(selectedRange)
    }
    
}
