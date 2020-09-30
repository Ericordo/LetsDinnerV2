//
//  NewEventViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 10/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift

protocol NewEventViewControllerDelegate: class {
    func newEventVCDidTapNext(controller: NewEventViewController)
    func newEventVCDdidTapProfile(controller: NewEventViewController)

    #warning("Delete before release")
    func eventDescriptionVCDidTapFinish(controller: NewEventViewController)
}

class NewEventViewController: LDNavigationViewController {
    // MARK: Properties
    private let stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var eventNameTextField = textField(placeholder: LabelStrings.eventName,
                                                    image: Images.titleIcon)
    private lazy var hostNameTextField = textField(placeholder: LabelStrings.host,
                                                   image: Images.hostIcon)
    private lazy var locationTextField = textField(placeholder: LabelStrings.location,
                                                   image: Images.locationIcon)
    private lazy var dateTextField = textField(placeholder: LabelStrings.date,
                                               image: Images.dateIcon)
    
    private let datePicker = LDDatePicker()

    private let infoInputView = InfoInputView()
    private let eventInputView = EventInputView()
    
    private let errorLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.allFieldsRequired
        label.textColor = .activeButton
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    #warning("Delete before release")
    private let quickFillButton : UIButton = {
        let button = UIButton()
        button.setTitle("☢️ Quick fill ☢️", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    private let quickEventButton : UIButton = {
        let button = UIButton()
        button.setTitle("☢️ Quick event ☢️", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    private var activeField: UITextField?
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let loadingView = LDLoadingView()
    
    weak var delegate: NewEventViewControllerDelegate?
    
    private let viewModel: NewEventViewModel
    
    //MARK: Init
    init(viewModel: NewEventViewModel, delegate: NewEventViewControllerDelegate) {
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
        addKeyboardNotifications()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StepStatus.currentStep = .newEventVC
        self.viewModel.validateInfo()
    }
    
    // MARK: ViewModel Binding
    private func bindViewModel() {
        viewModel.eventName <~ eventNameTextField.reactive.continuousTextValues
        viewModel.host <~ hostNameTextField.reactive.continuousTextValues
        viewModel.location <~ locationTextField.reactive.continuousTextValues
        viewModel.dateString <~ dateTextField.reactive.continuousTextValues
        
        self.viewModel.eventName.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { name in
                self.eventNameTextField.text = name
        }
        
        self.viewModel.host.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { name in
                self.hostNameTextField.text = name
        }
        
        self.viewModel.location.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { name in
                self.locationTextField.text = name
        }
        
        self.viewModel.dateString.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { name in
                self.dateTextField.text = name
        }
        
        navigationBar.previousButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.delegate?.newEventVCDdidTapProfile(controller: self)
        }
        
        navigationBar.nextButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.eventNameTextField.animateEmpty()
            self.hostNameTextField.animateEmpty()
            self.locationTextField.animateEmpty()
            self.dateTextField.animateEmpty()
            self.view.endEditing(true)
            self.errorLabel.isHidden = self.viewModel.infoValidity.value
            if self.viewModel.infoValidity.value {
                self.viewModel.loadCustomRecipes()
            }
        }
        
        datePicker.reactive.controlEvents(.valueChanged).observeValues { datePicker in
            self.viewModel.date.value = datePicker.date
        }
        
        eventInputView.breakfastButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.updateEventName(LabelStrings.breakfast)
        }
        
        eventInputView.lunchButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.updateEventName(LabelStrings.lunch)
        }
        
        eventInputView.dinnerButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.updateEventName(LabelStrings.dinner)
        }
        
        infoInputView.addButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.activeField?.text = self.infoInputView.addButton.title(for: .normal)
            self.infoInputView.isHidden = true
            if self.hostNameTextField.isEditing {
                self.locationTextField.becomeFirstResponder()
            } else if self.locationTextField.isEditing {
                self.dateTextField.becomeFirstResponder()
            }
        }
    
        quickFillButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            let event = TestManager.quickFillIn()
            Event.shared.dinnerName = event.dinnerName
            Event.shared.hostName = event.hostName
            Event.shared.eventDescription = event.eventDescription
            Event.shared.dinnerLocation = event.dinnerLocation
            Event.shared.dateTimestamp = event.dateTimestamp
            self.delegate?.newEventVCDidTapNext(controller: self)
        }
        
        quickEventButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            let event = TestManager.createCaseOne()
            Event.shared.dinnerName = event.dinnerName
            Event.shared.hostName = event.hostName
            Event.shared.eventDescription = event.eventDescription
            Event.shared.dinnerLocation = event.dinnerLocation
            Event.shared.dateTimestamp = event.dateTimestamp
            self.delegate?.eventDescriptionVCDidTapFinish(controller: self)
        }
        
        viewModel.infoValidity.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] infoIsValid in
                guard let self = self else { return }
                let color = infoIsValid ? UIColor.activeButton : UIColor.inactiveButton
                self.navigationBar.nextButton.setTitleColor(color, for: .normal)
        }
        
        self.viewModel.isLoading.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.loadingView.frame = self.view.frame
                    self.view.addSubview(self.loadingView)
                    self.loadingView.start()
                } else {
                    self.loadingView.stop()
                }
        }
        
        self.viewModel.nextStepSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeCompleted {
                self.delegate?.newEventVCDidTapNext(controller: self)
        }
    }
    
    // MARK: Methods
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func updateEventName(_ name: String) {
        self.viewModel.eventName.value = name
        eventInputView.isHidden = true
        hostNameTextField.becomeFirstResponder()
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        
        navigationBar.titleLabel.text = LabelStrings.addEventDetails
        navigationBar.previousButton.setImage(Images.settingsButtonOutlined, for: .normal)
        scrollView.delegate = self
        errorLabel.isHidden = true
        dateTextField.inputView = datePicker
        view.addTapGestureToHideKeyboard()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(eventNameTextField)
        stackView.addArrangedSubview(hostNameTextField)
        stackView.addArrangedSubview(locationTextField)
        stackView.addArrangedSubview(dateTextField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(quickFillButton)
        contentView.addSubview(quickEventButton)
        view.addSubview(infoInputView)
        view.addSubview(eventInputView)
        addConstraints()
    }
    
    private func addConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(500)
            make.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        let textFieldHeight = 34
        eventNameTextField.snp.makeConstraints { make in
            make.height.equalTo(textFieldHeight)
        }
        
        hostNameTextField.snp.makeConstraints { make in
            make.height.equalTo(textFieldHeight)
        }
        
        locationTextField.snp.makeConstraints { make in
            make.height.equalTo(textFieldHeight)
        }
        
        dateTextField.snp.makeConstraints { make in
            make.height.equalTo(textFieldHeight)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom).offset(30)
        }
        
        quickFillButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
        
        quickEventButton.snp.makeConstraints { make in
            make.top.equalTo(quickFillButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
        
        infoInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(50)
        }
        
        eventInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(50)
        }
    }
    
    private func textField(placeholder: String, image: UIImage) -> UITextField {
        let textField = UITextField()
        textField.delegate = self
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .no
        textField.setLeftView(image: image)
        textField.placeholder = placeholder
        textField.returnKeyType = .next
        textField.tintColor = .activeButton
        textField.textColor = .textLabel
        textField.clearButtonMode = .always
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 17)
        return textField
    }
}
    //MARK: TextFieldDelegate
extension NewEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case eventNameTextField:
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
    
     func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        switch textField {
        case eventNameTextField:
            infoInputView.isHidden = true
            eventInputView.isHidden = false
        case hostNameTextField:
            eventInputView.isHidden = true
            infoInputView.isHidden = defaults.username.isEmpty
            infoInputView.assignInfoInput(textField: hostNameTextField, info: defaults.username)
        case locationTextField:
            eventInputView.isHidden = true
            infoInputView.isHidden = defaults.address.isEmpty
            infoInputView.assignInfoInput(textField: locationTextField, info: defaults.address)
        case dateTextField:
            eventInputView.isHidden = true
            infoInputView.isHidden = true
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
}

// MARK: ScrollViewDelegate
extension NewEventViewController: UIScrollViewDelegate {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        var rectangle = self.view.frame
        rectangle.size.height -= keyboardFrame.height
        if let activeField = activeField {
            if !rectangle.contains(activeField.frame.origin) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }

//        if activeField == locationTextField || activeField == hostNameTextField {
//            showInputView(inputView: self.infoInputView, offset: keyboardFrame.height, duration: duration, animationCurve: animationCurve )
//        } else {
//            showInputView(inputView: self.eventInputView, offset: keyboardFrame.height, duration: duration, animationCurve: animationCurve )
//        }
        
        showInputView(offset: keyboardFrame.height)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        removeInputViews()
    }
    
    private func showInputView(offset: CGFloat) {
        
        var offset = offset
        #warning("Temporary solve for iPad ios13")
        if UIDevice.current.userInterfaceIdiom == .pad {
            if #available(iOS 13.0, *) { offset += 20 }
        }
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1) {
            self.eventInputView.snp.updateConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(50)
                make.bottom.equalToSuperview().offset(-offset)
            }
            self.infoInputView.snp.updateConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(50)
                make.bottom.equalToSuperview().offset(-offset)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func removeInputViews() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.7) {
            self.eventInputView.snp.updateConstraints { make in
               make.bottom.equalToSuperview().offset(50)
               self.view.layoutIfNeeded()
           }
            self.infoInputView.snp.updateConstraints { make in
               make.bottom.equalToSuperview().offset(50)
               self.view.layoutIfNeeded()
           }
        }
    }
}

