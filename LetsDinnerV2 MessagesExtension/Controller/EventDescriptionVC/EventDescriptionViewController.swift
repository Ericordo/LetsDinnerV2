//
//  EventDescriptionViewControllerBis.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol EventDescriptionViewControllerDelegate: class {
    func eventDescriptionVCDidTapPrevious(controller: EventDescriptionViewController)
    func eventDescriptionVCDidTapFinish(controller: EventDescriptionViewController)
}

class EventDescriptionViewController: UIViewController {
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cookLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var recipesCollectionView: UICollectionView!
    
    weak var delegate: EventDescriptionViewControllerDelegate?
    private let selectedRecipes = Event.shared.selectedRecipes
    private let selectedCustomRecipes = Event.shared.selectedCustomRecipes
    private var allRecipesTitles = [String]()
    private var placeholderLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .eventDescriptionVC
        
        NotificationCenter.default.post(name: Notification.Name("didGoToNextStep"), object: nil, userInfo: ["step": 4])

        
        descriptionTextView.delegate = self
        recipesCollectionView.delegate = self
        recipesCollectionView.dataSource = self
        recipesCollectionView.register(UINib(nibName: CellNibs.recipeCVCell, bundle: nil), forCellWithReuseIdentifier: CellNibs.recipeCVCell)
        
        selectedRecipes.forEach { recipe in
            allRecipesTitles.append(recipe.title ?? "")
        }
        selectedCustomRecipes.forEach { customRecipe in
            allRecipesTitles.append(customRecipe.title)
        }
        setupUI()
        setupSwipeGesture()
    }
    
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 17)
        recipesCollectionView.collectionViewLayout = layout

        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
        descriptionTextView.tintColor = Colors.highlightRed
        descriptionTextView.backgroundColor = nil
        descriptionTextView.bounds.inset(by: UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0))
        
        placeholderLabel.text = LabelStrings.whatsThePlan
        placeholderLabel.numberOfLines = 0
        placeholderLabel.sizeToFit()
        
        checkForExistingDescription()
        
        descriptionTextView.addSubview(placeholderLabel)
        
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = Colors.seperatorGrey
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.isHidden = !descriptionTextView.text.isEmpty
        descriptionTextView.becomeFirstResponder()
        
//        progressView.progressTintColor = Colors.newGradientRed
//        progressView.trackTintColor = .white
//        progressView.progress = 3/5
//        progressView.setProgress(4/5, animated: true)
        
        cookLabel.text = "\(Event.shared.servings) SERVINGS OF"
        if Event.shared.selectedRecipes.isEmpty && Event.shared.selectedCustomRecipes.isEmpty {
//            cookLabel.isHidden = true
//            recipesCollectionView.isHidden = true
            cookLabel.removeFromSuperview()
            recipesCollectionView.removeFromSuperview()
            
            titleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 25).isActive = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.post(name: Notification.Name("didGoToNextStep"), object: nil, userInfo: ["step": 4])
    }
    
    private func setupSwipeGesture() {
        self.view.addSwipeGestureRecognizer(action: {self.delegate?.eventDescriptionVCDidTapPrevious(controller: self)})
    }
    
    private func checkForExistingDescription() {
        if Event.shared.eventDescription != "" {
            descriptionTextView.text = Event.shared.eventDescription
        }
    }
    
    

    @IBAction func didTapPrevious(_ sender: UIButton) {
        delegate?.eventDescriptionVCDidTapPrevious(controller: self)
    }
    
    @IBAction func didTapNext(_ sender: UIButton) {
           guard let text = descriptionTextView.text else { return }
             if text.isEmpty {
//                 let refreshAlert = UIAlertController(title: MessagesToDisplay.descriptionPrompt, message: "", preferredStyle: UIAlertController.Style.alert)
//                 refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//                     self.descriptionTextView.becomeFirstResponder()
//                 }))
//                 present(refreshAlert, animated: true, completion: nil)
                Event.shared.eventDescription = ""
             } else {
                 Event.shared.eventDescription = text
             }
        delegate?.eventDescriptionVCDidTapFinish(controller: self)
    }
    
    
    
}

extension EventDescriptionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRecipesTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recipeCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellNibs.recipeCVCell, for: indexPath) as! RecipeCVCell
        let recipeTitle = allRecipesTitles[indexPath.row]
        recipeCVCell.configureCell(recipeTitle: recipeTitle)
        return recipeCVCell
    }
    
    
}

extension EventDescriptionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 30
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
        Event.shared.eventDescription = descriptionTextView.text ?? ""
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
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
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

