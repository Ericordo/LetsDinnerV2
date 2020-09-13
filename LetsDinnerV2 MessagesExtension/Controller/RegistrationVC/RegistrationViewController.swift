//
//  RegistrationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 17/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift
import CoreLocation

enum ImageState {
    case addPic
    case deleteOrModifyPic
}

enum MeasurementSystem : String {
    case metric
    case imperial
}

protocol RegistrationViewControllerDelegate : class {
    func registrationVCDidTapSaveButton(previousStep: StepTracking)
    func registrationVCDidTapCancelButton()
}

class RegistrationViewController: LDNavigationViewController {
    // MARK: Properties
    private let headerView : UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        return view
    }()
    
    private let userPic : UIImageView = {
        let iv = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 120, height: 120)))
        iv.contentMode = .scaleAspectFill
        iv.image = Images.profilePlaceholder
        iv.layer.cornerRadius = iv.frame.height / 2
        iv.layer.masksToBounds = true
        iv.kf.indicatorType = .activity
        return iv
    }()
    
    private let addPicButton : UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(.activeButton, for: .normal)
        button.setTitle(LabelStrings.addImage, for: .normal)
        return button
    }()
    
    private lazy var headerSeparator = separator()
    
    private let infoLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.font = .systemFont(ofSize: 13)
        label.text = LabelStrings.personalInfo
        return label
    }()
    
    private lazy var firstSeparator = separator()
    private lazy var secondSeparator = separator()
    private lazy var thirdSeparator = separator()
    private lazy var fourthSeparator = separator()
    private lazy var fifthSeparator = separator()
    private lazy var sixthSeparator = separator()
    private lazy var seventhSeparator = separator()
    
    private let firstNameTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = LabelStrings.firstName
        textField.autocapitalizationType = .words
        textField.returnKeyType = .next
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.textColor = .textLabel
        textField.font = .systemFont(ofSize: 17)
        textField.tintColor = .activeButton
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let lastNameTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = LabelStrings.lastName
        textField.returnKeyType = .next
        textField.autocapitalizationType = .words
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.textColor = .textLabel
        textField.font = .systemFont(ofSize: 17)
        textField.tintColor = .activeButton
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let addressTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = LabelStrings.address
        textField.borderStyle = .none
        textField.autocapitalizationType = .sentences
        textField.clearButtonMode = .whileEditing
        textField.textColor = .textLabel
        textField.font = .systemFont(ofSize: 17)
        textField.tintColor = .activeButton
        textField.textContentType = .location
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let locationButton : UIButton = {
        let button = UIButton()
        button.setImage(Images.locationIcon, for: .normal)
        return button
    }()

    private let systemLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.font = .systemFont(ofSize: 13)
        label.text = LabelStrings.measurementSystem
        return label
    }()
    
    private let errorLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .activeButton
        label.text = LabelStrings.enterFullName
        return label
    }()
    
    private let metricImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = Images.checkmark.withRenderingMode(.alwaysTemplate)
        return iv
    }()
    
    private let imperialImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = Images.checkmark.withRenderingMode(.alwaysTemplate)
        return iv
    }()
    
    private let metricLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.metric
        return label
    }()
    
    private let imperialLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.imperial
        label.textColor = .textLabel
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let metricView = UIView()
    
    private let imperialView = UIView()
        
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let picturePicker = UIImagePickerController()
    
    private let topViewMinHeight: CGFloat = 90

    private let topViewMaxHeight: CGFloat = 170
    
    private let viewModel : RegistrationViewModel
    
    private var activeField: UITextField?
    
    private var imageState : ImageState = .addPic
    
    private let locationManager = CLLocationManager()
    
    private weak var delegate: RegistrationViewControllerDelegate?
    
    let previousStep: StepTracking
    
    private let loadingView = LDLoadingView()
    
    private let actionSheetManager = ActionSheetManager()
    
    // MARK: Init
    init(viewModel: RegistrationViewModel,
         previousStep: StepTracking,
         delegate: RegistrationViewControllerDelegate) {
        self.viewModel = viewModel
        self.previousStep = previousStep
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
        setupNotifications()
        bindViewModel()
        presentWelcomeVCIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if StepStatus.currentStep == .initialVC || StepStatus.currentStep == .newEventVC {
            StepStatus.currentStep = .registrationVC
        }
    }
    
    // MARK: ViewModel Binding
    private func bindViewModel() {
        viewModel.firstName <~ firstNameTextField.reactive.continuousTextValues
        viewModel.lastName <~ lastNameTextField.reactive.continuousTextValues
        viewModel.address <~ addressTextField.reactive.continuousTextValues
        
        self.viewModel.firstName.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { name in
                self.firstNameTextField.text = name
                self.updateInitials()
        }
        
        self.viewModel.lastName.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { name in
                self.lastNameTextField.text = name
                self.updateInitials()
        }
        
        self.viewModel.address.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { name in
                self.addressTextField.text = name
                self.locationButton.isHidden = name.count > 30
        }
        
        self.viewModel.profilePicData.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { data in
                if data == nil {
                    defaults.profilePicUrl = ""
                    CloudManager.shared.saveUserInfoOnCloud("", key: Keys.profilePicUrl)
                    self.checkUsername()
                } else {
                    self.userPic.image = UIImage(data: data!)
                    self.imageState = .deleteOrModifyPic
                    self.addPicButton.setTitle(ButtonTitle.edit, for: .normal)
                }
        }

        self.viewModel.isLoading.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.view.addSubview(self.loadingView)
                    self.loadingView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    self.loadingView.start()
                } else {
                    self.loadingView.stop()
                }
        }
        
        self.viewModel.dataUploadSignal.observe(on: UIScheduler())
            .observeResult { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.showBasicAlert(title: AlertStrings.oops, message: error.localizedDescription)
                self.checkUsername()
            case.success(()):
                self.delegate?.registrationVCDidTapSaveButton(previousStep: self.previousStep)
            }
        }
        
        locationButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.findCurrentLocation()
        }
        
        addPicButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            switch self.imageState {
            case .addPic:
                self.presentPicker()
            case .deleteOrModifyPic:
                self.presentDeleteOrModifyOptions()
            }
        }
        
        navigationBar.previousButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.delegate?.registrationVCDidTapCancelButton()
        }
        
        navigationBar.nextButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            let alert = self.actionSheetManager.presentDoneActionSheet(
                sourceView: self.navigationBar.nextButton,
                message: AlertStrings.doneActionSheetMessage,
                saveActionCompletion: { _ in
                    self.view.endEditing(true)
                    self.firstNameTextField.animateEmpty()
                    self.lastNameTextField.animateEmpty()
                    self.errorLabel.isHidden = self.viewModel.infoIsValid()
                    if self.viewModel.infoIsValid() {
                       self.viewModel.saveUserInformation()
                    }},
                discardActionCompletion: { _ in
                    self.delegate?.registrationVCDidTapCancelButton() })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Methods
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func presentWelcomeVCIfNeeded() {
        if defaults.bool(forKey: Keys.onboardingComplete) != true {
            let welcomeVC = WelcomeViewController()
            welcomeVC.modalPresentationStyle = .overFullScreen
            self.present(welcomeVC, animated: true, completion: nil)
        }
    }
    
    private func updateInitials() {
        if imageState == .addPic && headerView.frame.height == topViewMaxHeight {
            if !viewModel.firstName.value.isEmpty {
                userPic.setImage(string: viewModel.firstName.value + " " + viewModel.lastName.value,
                                 color: .lightGray,
                                 circular: true,
                                 stroke: true,
                                 strokeColor: Colors.customGray,
                                 textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 50, weight: .light),
                                                  NSAttributedString.Key.foregroundColor: UIColor.white])
            } else {
                userPic.image = Images.profilePlaceholder
            }
        }
    }
    
    private func checkUsername() {
        if !defaults.username.isEmpty {
            userPic.setImage(string: defaults.username.initials,
                             color: .lightGray,
                             circular: true,
                             stroke: true,
                             strokeColor: Colors.customGray,
                             textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 50, weight: .light),
                                              NSAttributedString.Key.foregroundColor: UIColor.white])
            addPicButton.setTitle(ButtonTitle.addImage, for: .normal)
        } else {
            userPic.image = Images.profilePlaceholder
            addPicButton.setTitle(ButtonTitle.addImage, for: .normal)
        }
        imageState = .addPic
    }
    
    private func setupMeasurementSystem(_ system: MeasurementSystem) {
        switch system {
        case .metric:
            metricImageView.image = Images.checkmark.withRenderingMode(.alwaysTemplate)
            metricImageView.tintColor = .activeButton
            imperialImageView.image = nil
        case .imperial:
            imperialImageView.image = Images.checkmark.withRenderingMode(.alwaysTemplate)
            imperialImageView.tintColor = .activeButton
            metricImageView.image = nil
        }
        defaults.measurementSystem = system.rawValue
        CloudManager.shared.saveUserInfoOnCloud(system.rawValue, key: Keys.measurementSystem)
    }
    
    @objc private func didTapImperialView() {
        setupMeasurementSystem(.imperial)
    }
    
    @objc private func didTapMetricView() {
        setupMeasurementSystem(.metric)
    }
    
    private func findCurrentLocation() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
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
    
    private func presentDeleteOrModifyOptions() {
        let alert = actionSheetManager.presentEditImageActionSheet(
            sourceView: self.addPicButton,
            changeActionCompletion: { _ in
                self.presentPicker() },
            deleteActionCompletion: { _ in
                self.viewModel.deleteProfilePicture()}
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupProfilePicture() {
        if let imageURL = URL(string: defaults.profilePicUrl) {
            addPicButton.isHidden = true
            userPic.kf.setImage(with: imageURL, placeholder: Images.profilePlaceholder) { result in
                switch result {
                case .success:
                    self.addPicButton.setTitle(ButtonTitle.edit, for: .normal)
                    self.imageState = .deleteOrModifyPic
                case .failure:
                    self.showBasicAlert(title: AlertStrings.oops, message: AlertStrings.errorFetchImage)
                    self.checkUsername()
                }
                self.addPicButton.isHidden = false
            }
        } else if !defaults.username.isEmpty {
            userPic.setImage(string: defaults.username.initials,
                             color: .lightGray,
                             circular: true,
                             stroke: true,
                             strokeColor: Colors.customGray,
                             textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 50, weight: .light),
                                              NSAttributedString.Key.foregroundColor: UIColor.white])
            addPicButton.setTitle(LabelStrings.addImage, for: .normal)
            imageState = .addPic
        } else {
            userPic.image = Images.profilePlaceholder
            addPicButton.setTitle(LabelStrings.addImage, for: .normal)
            imageState = .addPic
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        navigationBar.titleLabel.text = LabelStrings.profile
        #warning("fix previous button leading constraint")
        navigationBar.previousButton.setTitle(AlertStrings.cancel, for: .normal)
        navigationBar.previousButton.isHidden = true
        navigationBar.nextButton.setTitle(ButtonTitle.done, for: .normal)
        progressViewContainer.isHidden = true
        errorLabel.isHidden = true
        scrollView.delegate = self
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight + 10, left: 0, bottom: 0, right: 0)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        headerView.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: topViewMaxHeight))
        picturePicker.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        addressTextField.delegate = self
        setupProfilePicture()
        let tapGestureToHideKeyboard = UITapGestureRecognizer(target: self.view,
                                                              action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGestureToHideKeyboard)
        if let system = MeasurementSystem(rawValue: defaults.measurementSystem) {
            setupMeasurementSystem(system)
        } else {
            setupMeasurementSystem(.metric)
        }
        let tapGestureMetric = UITapGestureRecognizer(target: self, action: #selector(didTapMetricView))
        let tapGestureImperial = UITapGestureRecognizer(target: self, action: #selector(didTapImperialView))
        imperialView.addGestureRecognizer(tapGestureImperial)
        metricView.addGestureRecognizer(tapGestureMetric)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(infoLabel)
        contentView.addSubview(firstSeparator)
        contentView.addSubview(firstNameTextField)
        contentView.addSubview(secondSeparator)
        contentView.addSubview(lastNameTextField)
        contentView.addSubview(thirdSeparator)
        contentView.addSubview(addressTextField)
        contentView.addSubview(locationButton)
        contentView.addSubview(fourthSeparator)
        contentView.addSubview(errorLabel)
        contentView.addSubview(systemLabel)
        contentView.addSubview(fifthSeparator)
        contentView.addSubview(metricView)
        metricView.addSubview(metricLabel)
        metricView.addSubview(metricImageView)
        contentView.addSubview(sixthSeparator)
        contentView.addSubview(imperialView)
        imperialView.addSubview(imperialLabel)
        imperialView.addSubview(imperialImageView)
        contentView.addSubview(seventhSeparator)
        view.addSubview(headerView)
        headerView.addSubview(addPicButton)
        headerView.addSubview(userPic)
        headerView.addSubview(headerSeparator)
        addConstraints()
    }
    
    private func addConstraints() {
        headerView.snp.makeConstraints { make in
            make.height.equalTo(topViewMaxHeight)
            make.top.equalTo(self.navigationBar.snp.bottom)
            make.trailing.leading.equalToSuperview()
        }
        
        addPicButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        
        userPic.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(userPic.snp.height)
            make.bottom.equalTo(addPicButton.snp.top).offset(-8)
            make.centerX.equalToSuperview()
        }
        
        headerSeparator.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        scrollView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(600)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(16)
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview()
        }
        
        firstSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(infoLabel.snp.bottom).offset(5)
        }
        
        firstNameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(44)
            make.top.equalTo(firstSeparator.snp.bottom)
        }
        
        secondSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(firstNameTextField.snp.bottom)
        }
        
        lastNameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(44)
            make.top.equalTo(secondSeparator.snp.bottom)
        }
        
        thirdSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(lastNameTextField.snp.bottom)
        }
        
        addressTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(44)
            make.top.equalTo(thirdSeparator.snp.bottom)
        }
        
        locationButton.snp.makeConstraints { make in
            make.centerY.equalTo(addressTextField.snp.centerY)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        fourthSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(addressTextField.snp.bottom)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.height.equalTo(17)
            make.centerX.equalToSuperview()
            make.top.equalTo(fourthSeparator.snp.bottom).offset(10)
        }
        
        systemLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(16)
            make.top.equalTo(errorLabel.snp.bottom).offset(15)
            make.trailing.equalToSuperview()
        }
        
        fifthSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(systemLabel.snp.bottom).offset(5)
        }
        
        metricView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(fifthSeparator.snp.bottom)
        }
        
        metricLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        metricImageView.snp.makeConstraints { make in
            make.centerX.equalTo(locationButton.snp.centerX)
            make.centerY.equalToSuperview()
        }
        
        sixthSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(metricView.snp.bottom)
        }
        
        imperialView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(sixthSeparator.snp.bottom)
        }
        
        imperialLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        imperialImageView.snp.makeConstraints { make in
            make.centerX.equalTo(locationButton.snp.centerX)
            make.centerY.equalToSuperview()
        }
        
        seventhSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(imperialView.snp.bottom)
        }
    }
        
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight + 10, left: 0, bottom: keyboardFrame.height, right: 0)
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

    // MARK: UITextField Delegate
extension RegistrationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
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

    // MARK: UIScrollViewDelegate
extension RegistrationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        userPic.layer.cornerRadius = userPic.frame.height / 2
        if yOffset <= -topViewMaxHeight {
            headerView.snp.remakeConstraints { make in
                make.top.equalTo(navigationBar.snp.bottom)
                make.trailing.leading.equalToSuperview()
                make.height.equalTo(self.topViewMaxHeight)
            }
            updateInitials()
        } else if yOffset < -topViewMinHeight {
            headerView.snp.remakeConstraints { make in
                make.top.equalTo(navigationBar.snp.bottom)
                make.trailing.leading.equalToSuperview()
                make.height.equalTo(yOffset * -1)
            }
        } else {
            headerView.snp.remakeConstraints { make in
                make.top.equalTo(navigationBar.snp.bottom)
                make.trailing.leading.equalToSuperview()
                make.height.equalTo(self.topViewMinHeight)
            }
        }
        
        if headerView.frame.height == topViewMaxHeight {
            addPicButton.alpha = 1
        } else {
            addPicButton.alpha = 0
        }
    }
}

    // MARK: Image Picker Delegate
extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageEdited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let imageEditedData = imageEdited.jpegData(compressionQuality: 0.4) else { return }
        viewModel.profilePicData.value = imageEditedData
        picturePicker.dismiss(animated: true, completion: nil)
    }
}
    // MARK: CLLocation Manager Delegate
extension RegistrationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: locValue.latitude, longitude:locValue.longitude)) { (places, error) in
            if error == nil {
                if let places = places {
                    let location = places[0]
                    if let name = location.name,
                        var country = location.country,
                        var adminstrationArea = location.administrativeArea,
                        var subArea = location.subAdministrativeArea {
                        subArea = " " + subArea
                        adminstrationArea = " " + adminstrationArea
                        country = " " + country
                        self.viewModel.address.value = name + subArea + adminstrationArea
                    }
                }
            }
        }
    }
}




