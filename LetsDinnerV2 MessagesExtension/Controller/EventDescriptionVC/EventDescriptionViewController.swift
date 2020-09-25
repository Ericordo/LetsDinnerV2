//
//  EventDescriptionViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 12/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift

protocol EventDescriptionViewControllerDelegate: class {
    func eventDescriptionVCDidTapPrevious(controller: EventDescriptionViewController)
    func eventDescriptionVCDidTapFinish(controller: EventDescriptionViewController)
}

class EventDescriptionViewController: LDNavigationViewController {
    // MARK: Properties
    private let servingsLabel : UILabel = {
        let label = UILabel()
        label.text = String.localizedStringWithFormat(LabelStrings.servingsOf, Event.shared.servings)
        label.textColor = .secondaryTextLabel
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return label
    }()

    private let recipesCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 17)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .backgroundColor
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.text = LabelStrings.whatsThePlan.uppercased()
        return label
    }()
    
    private let descriptionTextView : UITextView = {
        let textView = UITextView()
        textView.tintColor = .activeButton
        textView.backgroundColor = nil
        textView.bounds.inset(by: UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0))
        textView.textColor = .textLabel
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
 
    private lazy var placeholderLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.eventPlaceholder
        label.numberOfLines = 0
        label.sizeToFit()
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 16)
        label.frame.origin = CGPoint(x: 5, y: (descriptionTextView.font?.pointSize)! / 2)
        return label
    }()
    
    weak var delegate: EventDescriptionViewControllerDelegate?
    
    private let viewModel: EventDescriptionViewModel
    
    // MARK: Init
    init(viewModel: EventDescriptionViewModel, delegate: EventDescriptionViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        addKeyboardNotifications()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StepStatus.currentStep = .eventDescriptionVC
    }
    
    // MARK: ViewModel Binding
    private func bindViewModel() {
        viewModel.description <~ descriptionTextView.reactive.continuousTextValues
        
        navigationBar.previousButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.delegate?.eventDescriptionVCDidTapPrevious(controller: self)
        }
        
        navigationBar.nextButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            Event.shared.eventDescription = self.viewModel.description.value
            self.delegate?.eventDescriptionVCDidTapFinish(controller: self)
        }
        
        self.viewModel.description.producer
        .observe(on: UIScheduler())
        .take(duringLifetimeOf: self)
        .startWithValues { [weak self] description in
            guard let self = self else { return }
            self.descriptionTextView.text = description
            self.placeholderLabel.isHidden = !description.isEmpty
        }
    }

    // MARK: Methods
    private func setupUI() {
        view.backgroundColor = .backgroundColor
//        view.addSwipeGestureRecognizer(action: { self.delegate?.eventDescriptionVCDidTapPrevious(controller: self) })
        view.addTapGestureToHideKeyboard()
        navigationBar.titleLabel.text = LabelStrings.addDescription
        navigationBar.previousButton.setImage(Images.chevronLeft, for: .normal)
        navigationBar.previousButton.setTitle(LabelStrings.things, for: .normal)
        descriptionTextView.delegate = self
        if !viewModel.allRecipeTitles.isEmpty {
            view.addSubview(servingsLabel)
            view.addSubview(recipesCollectionView)
        }
        view.addSubview(titleLabel)
        view.addSubview(descriptionTextView)
        descriptionTextView.addSubview(placeholderLabel)
        descriptionTextView.becomeFirstResponder()
        addConstraints()
    }
    
    private func setupCollectionView() {
        recipesCollectionView.delegate = self
        recipesCollectionView.dataSource = self
        recipesCollectionView.register(RecipeCVCell.self,
                                       forCellWithReuseIdentifier: RecipeCVCell.reuseID)
    }
    
    private func addConstraints() {
        if !viewModel.allRecipeTitles.isEmpty {
            servingsLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.top.equalTo(self.navigationBar.snp.bottom).offset(20)
            }
            
            recipesCollectionView.snp.makeConstraints { make in
                make.top.equalTo(servingsLabel.snp.bottom).offset(10)
                make.height.equalTo(22)
                make.leading.trailing.equalToSuperview()
            }
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            if !viewModel.allRecipeTitles.isEmpty {
                make.top.equalTo(recipesCollectionView.snp.bottom).offset(40)
            } else {
                make.top.equalTo(navigationBar.snp.bottom).offset(25)
            }
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(11)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
    // MARK: CollectionViewDelegate
extension EventDescriptionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.allRecipeTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recipeCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCVCell.reuseID, for: indexPath) as! RecipeCVCell
        let recipeTitle = self.viewModel.allRecipeTitles[indexPath.row]
        recipeCVCell.configureCell(recipeTitle: recipeTitle)
        return recipeCVCell
    }
}

extension EventDescriptionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
    // MARK: TextViewDelegate
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
        let remainingChars = self.viewModel.maxCharsLength - textView.text.count
        if remainingChars == 0 {
            self.showBasicAlert(title: AlertStrings.oops,
                                message: LabelStrings.maxCount)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let stringRange = Range(range, in: textView.text) else { return false }
        let updatedText = textView.text.replacingCharacters(in: stringRange, with: text)
        if updatedText.count > viewModel.maxCharsLength {
            descriptionTextView.resignFirstResponder()
        }
        return updatedText.count <= viewModel.maxCharsLength
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
