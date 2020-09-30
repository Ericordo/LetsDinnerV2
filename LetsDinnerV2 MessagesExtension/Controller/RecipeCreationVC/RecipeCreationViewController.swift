//
//  RecipeCreationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 10/08/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift
import FirebaseAnalytics

protocol RecipeCreationVCDelegate: class {
    func recipeCreationVCDidTapDone()
}

class RecipeCreationViewController: UIViewController {
    
    private let headerView : UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        return view
    }()
    
    private let recipeImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 15
        iv.image = Images.imagePlaceholderBig
        iv.layer.masksToBounds = true
        iv.kf.indicatorType = .activity
        return iv
    }()
    
    private let addImageButton : UIButton = {
         let button = UIButton()
         button.titleLabel?.font = .systemFont(ofSize: 17)
         button.setTitleColor(.activeButton, for: .normal)
         button.setTitle(LabelStrings.addImage, for: .normal)
         return button
     }()
    
    private let recipeTitleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        return label
    }()
     
     private let editButton : UIButton = {
         let button = UIButton()
         button.setTitleColor(.activeButton, for: .normal)
         button.setTitle(" \(LabelStrings.edit)", for: .normal)
         button.setImage(Images.editButton, for: .normal)
         return button
     }()
    
    private lazy var headerSeparator = separator()
    
    private let informationLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.font = .systemFont(ofSize: 13)
        label.text = LabelStrings.information
        return label
    }()
    
    private lazy var firstSeparator = separator()
    
    private let recipeNameTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = LabelStrings.recipeNamePlaceholder
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
    
    private lazy var secondSeparator = separator()
    
    private let servingsLabel : UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let servingsStepper : UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 2
        stepper.maximumValue = 12
        stepper.stepValue = 1
        return stepper
    }()
    
    private lazy var thirdSeparator = separator()
    
    private let ingredientsContainer = UIView()
    private let ingredientsVC : CreationStepViewController
    
    private let stepsContainer = UIView()
    private let stepsVC : CreationStepViewController
    
    private let commentsContainer = UIView()
    private let commentsVC : CreationStepViewController
    
    let doneButton : LDNavButton = {
        let button = LDNavButton()
        button.setTitle(LabelStrings.done, for: .normal)
        button.contentHorizontalAlignment = .trailing
        return button
    }()

    private let bottomView : UIView = {
        let view = UIView()
        view.backgroundColor = .bottomViewColor
        return view
    }()
    
    private let sectionsStackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalCentering
        sv.alignment = .fill
        sv.spacing = 30
        return sv
    }()
    
    private var activeField: UITextField?
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let picturePicker = UIImagePickerController()
    
    private var imageState: ImageState = .addPic
    
    private var tapGestureToHideKeyboard = UITapGestureRecognizer()
    
    private let loadingView = LDLoadingView()
    
    private let textFieldAllowedCharacters = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."
    
    private let topViewMinHeight : CGFloat = 55
    private let topViewMaxHeight : CGFloat = 180
    private let bottomViewHeight : CGFloat = UIDevice.current.type == .iPad ? 90 : (UIDevice.current.hasHomeButton ? 60 : 90)
    private let minimumScrollViewHeight: CGFloat = 300
        
    private let actionSheetManager = ActionSheetManager()
    
    weak var recipeCreationVCDelegate: RecipeCreationVCDelegate?
    
    private let viewModel: RecipeCreationViewModel
    
    init(viewModel: RecipeCreationViewModel, delegate: RecipeCreationVCDelegate?) {
        self.viewModel = viewModel
        self.recipeCreationVCDelegate = delegate
        self.ingredientsVC = CreationStepViewController(viewModel: viewModel,
                                                        section: .ingredient)
        self.stepsVC = CreationStepViewController(viewModel: viewModel,
                                                  section: .step)
        self.commentsVC = CreationStepViewController(viewModel: viewModel,
                                                     section: .comment)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addChildController(ingredientsVC, to: ingredientsContainer)
        addChildController(stepsVC, to: stepsContainer)
        addChildController(commentsVC, to: commentsContainer)
        if self.viewModel.editingAllowed {
            self.addBottomView()
        }
        setupObservers()
        bindViewModel()
        self.updateLayoutConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presentCreateRecipeWelcomeVCIfNeeded()
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        self.updateLayoutConstraints()
    }
    
    private func bindViewModel() {
        viewModel.servings <~ servingsStepper.reactive.values.map { Int($0) }
        viewModel.recipeName <~ recipeNameTextField.reactive.continuousTextValues
        
        editButton.reactive
            .controlEvents(.touchUpInside)
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] _ in
                self.viewModel.didTapEdit()
        }
        
        doneButton.reactive
            .controlEvents(.touchUpInside)
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] _ in
                self.view.endEditing(true)
                self.viewModel.didTapDone()
        }
        
        addImageButton.reactive
            .controlEvents(.touchUpInside)
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] _ in
                self.handleRecipeImage()
        }
        
        self.viewModel.servings.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] servings in
                self.servingsLabel.text = String.localizedStringWithFormat(LabelStrings.servingLabel, String(servings))
                self.servingsStepper.value = Double(servings)
        }
        
        self.viewModel.recipeName.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] name in
                self.recipeTitleLabel.text = name
                self.recipeNameTextField.text = name
        }
        
        self.viewModel.recipePicData.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] data in
                if data == nil {
                    self.recipeImageView.image = Images.imagePlaceholderBig
                } else {
                    self.recipeImageView.image = UIImage(data: data!)
                    self.imageState = .deleteOrModifyPic
                    self.addImageButton.setTitle(ButtonTitle.editImage, for: .normal)
                }
        }
        
        self.viewModel.downloadUrl.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .skipNil()
            .startWithValues { [unowned self] downloadUrl in
                self.setupRecipePicture(downloadUrl)
        }
        
        self.viewModel.creationMode.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] creationMode in
                self.setupCreationInterface(creationMode)
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
        
        self.viewModel.doneActionSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] _ in
                self.presentDoneActionSheet()
        }
        
        self.viewModel.editActionSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] _ in
                self.presentEditActionSheet()
        }
        
        self.viewModel.recipeSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues({ [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    if error == .recipeNameMissing {
                        self.recipeNameTextField.shake()
                        self.showErrorBanner(message: error.description)
                        return
                    }
                    Analytics.logEvent(error.description, parameters: nil)
                    self.showBasicAlert(title: AlertStrings.oops,
                                        message: error.description)
                case.success(()):
                    self.recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
                    self.dismiss(animated: true, completion: nil)
                }
            })
    }
    
    private func updateLayoutConstraints() {
        let ingredientsContainerHeight : CGFloat = ingredientsVC.preferredContentSize.height
        let stepsContainerHeight : CGFloat = stepsVC.preferredContentSize.height
        let commentsContainerHeight : CGFloat = commentsVC.preferredContentSize.height
        
        self.ingredientsContainer.snp.updateConstraints { make in
            make.height.equalTo(ingredientsContainerHeight)
        }
        
        self.stepsContainer.snp.updateConstraints { make in
            make.height.equalTo(stepsContainerHeight)
        }
        
        self.commentsContainer.snp.updateConstraints { make in
            make.height.equalTo(commentsContainerHeight)
        }
        
        let containersHeight = ingredientsContainerHeight + stepsContainerHeight + commentsContainerHeight
        
        self.contentView.snp.updateConstraints { make in
            make.height.equalTo(minimumScrollViewHeight + containersHeight)
        }
        
        self.view.layoutIfNeeded()
    }
    
    private func presentDoneActionSheet() {
        let alert = actionSheetManager.presentDoneActionSheet(
            sourceView: self.doneButton,
            message: AlertStrings.doneActionSheetMessage,
            saveActionCompletion: { _ in
                Analytics.logEvent("save_or_update_recipe", parameters: nil)
                self.viewModel.recipe == nil ? self.viewModel.saveRecipe() : self.viewModel.updateRecipe()
        },
            discardActionCompletion: { _ in
                self.dismiss(animated: true, completion: nil) })
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showErrorBanner(message: String) {
        let banner = LDAlertBanner(message)
        banner.warning.textAlignment = .center
        headerView.addSubview(banner)
        banner.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        banner.appearAndDisappear()
    }
    
    private func setupCreationInterface(_ bool: Bool) {
        if self.viewModel.editingAllowed && !bool {
            self.addBottomView()
        } else {
            self.bottomView.removeFromSuperview()
        }
        self.addImageButton.isHidden = !bool
        self.recipeTitleLabel.isHidden = !self.addImageButton.isHidden
        self.servingsStepper.isHidden = self.addImageButton.isHidden
        self.secondSeparator.isHidden = self.addImageButton.isHidden
        let textFieldHeight = bool ? 44 : 0
        self.recipeNameTextField.snp.updateConstraints { make in
            make.height.equalTo(textFieldHeight)
        }
    }
    
    private func setupRecipePicture(_ downloadUrl: String) {
        recipeImageView.kf.setImage(with: URL(string: downloadUrl), placeholder: Images.imagePlaceholderBig) { result in
            switch result {
            case .success:
                self.addImageButton.setTitle(ButtonTitle.editImage, for: .normal)
                self.imageState = .deleteOrModifyPic
                self.viewModel.recipePicData.value = self.recipeImageView.image?.jpegData(compressionQuality: 0.4)
            case .failure:
                self.showBasicAlert(title: AlertStrings.oops, message: AlertStrings.retrieveImageErrorMessage)
            }
        }
    }
    
    private func addChildController(_ controller: UIViewController, to container: UIView) {
        addChild(controller)
        container.addSubview(controller.view)
        controller.view.frame = container.bounds
        controller.didMove(toParent: self)
    }
    
    private func handleRecipeImage() {
        switch imageState {
        case .addPic:
            presentImagePicker()
        case .deleteOrModifyPic:
            let alert = UIAlertController(title: "", message: AlertStrings.changeImageActionSheetMessage,
                                          preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = addImageButton
            alert.popoverPresentationController?.sourceRect = addImageButton.bounds
            let cancel = UIAlertAction(title: AlertStrings.cancel,
                                       style: .cancel,
                                       handler: nil)
            let change = UIAlertAction(title: AlertStrings.change,
                                       style: .default) { _ in
                self.presentImagePicker()
            }
            let delete = UIAlertAction(title: AlertStrings.delete,
                                       style: .destructive) { _ in
                self.addImageButton.setTitle(ButtonTitle.addImage, for: .normal)
                self.imageState = .addPic
                self.viewModel.downloadUrl.value = nil
                self.viewModel.recipePicData.value = nil
            }
            alert.addAction(cancel)
            alert.addAction(change)
            alert.addAction(delete)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func presentImagePicker() {
        picturePicker.popoverPresentationController?.sourceView = addImageButton
        picturePicker.popoverPresentationController?.sourceRect = addImageButton.bounds
        picturePicker.sourceType = .photoLibrary
        picturePicker.allowsEditing = true
        present(picturePicker, animated: true, completion: nil)
    }
    
    
    private func presentCreateRecipeWelcomeVCIfNeeded() {
        if defaults.bool(forKey: Keys.createCustomRecipeWelcomeVCVisited) != true {
            let welcomeVC = RecipeCreationWelcomeViewController()
            welcomeVC.modalPresentationStyle = .overFullScreen
            self.present(welcomeVC, animated: true, completion: nil)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        scrollView.delegate = self
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: bottomViewHeight, right: 0)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        recipeNameTextField.delegate = self
        ingredientsVC.textFieldView.textField.delegate = self
        stepsVC.textFieldView.textField.delegate = self
        commentsVC.textFieldView.textField.delegate = self
        picturePicker.delegate = self
        tapGestureToHideKeyboard = UITapGestureRecognizer(target: self.view,
                                                          action: #selector(UIView.endEditing(_:)))
//        tapGestureToHideKeyboard.delegate = self
        tapGestureToHideKeyboard.cancelsTouchesInView = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(informationLabel)
        contentView.addSubview(firstSeparator)
        contentView.addSubview(recipeNameTextField)
        contentView.addSubview(secondSeparator)
        contentView.addSubview(servingsLabel)
        contentView.addSubview(servingsStepper)
        contentView.addSubview(thirdSeparator)
        contentView.addSubview(ingredientsContainer)
        contentView.addSubview(stepsContainer)
        contentView.addSubview(commentsContainer)
        view.addSubview(headerView)
        headerView.addSubview(doneButton)
        headerView.addSubview(addImageButton)
        headerView.addSubview(recipeTitleLabel)
        headerView.addSubview(recipeImageView)
        headerView.addSubview(headerSeparator)
        addConstraints()
    }
    
    private func presentEditActionSheet() {
        let alert = actionSheetManager.presentEditActionSheet(sourceView: self.editButton,
                                                              message: String.localizedStringWithFormat(AlertStrings.editRecipeActionSheetMessage, self.viewModel.recipeName.value),
                                                              editActionCompletion: { _ in
                                                                self.viewModel.creationMode.value = true
        },
                                                              deleteActionCompletion: { _ in
                                                                guard let recipe = self.viewModel.recipe else { return }
                                                                self.viewModel.deleteRecipe(recipe)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addBottomView() {
        view.addSubview(bottomView)
        bottomView.addSubview(editButton)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(bottomViewHeight)
        }
        editButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(15)
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeVC),
                                               name: Notification.Name(rawValue: "WillTransition"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    private func addConstraints() {
        headerView.snp.makeConstraints { make in
            make.height.equalTo(topViewMaxHeight)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.leading.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-17)
            make.top.equalToSuperview().offset(5)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        
        recipeTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        
        recipeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.bottom.equalTo(addImageButton.snp.top).offset(-8)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(130)
            make.height.equalTo(recipeImageView.snp.width).multipliedBy(0.8)
        }
        
        headerSeparator.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        scrollView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(minimumScrollViewHeight)
        }
        
        informationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(16)
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
        }
        
        firstSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(informationLabel.snp.bottom).offset(5)
        }
        
        recipeNameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(44)
            make.top.equalTo(firstSeparator.snp.bottom)
        }
        
        secondSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(recipeNameTextField.snp.bottom)
        }
        
        servingsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(44)
            make.top.equalTo(secondSeparator.snp.bottom)
        }
        
        servingsStepper.snp.makeConstraints { make in
            make.centerY.equalTo(servingsLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        thirdSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(servingsLabel.snp.bottom)
        }
        
        ingredientsContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.top.equalTo(thirdSeparator.snp.bottom).offset(30)
            make.height.equalTo(200)
        }

        stepsContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.top.equalTo(ingredientsContainer.snp.bottom).offset(30)
            make.height.equalTo(200)
        }

        commentsContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview()
            make.top.equalTo(stepsContainer.snp.bottom).offset(30)
            make.height.equalTo(200)
        }
    }
}

extension RecipeCreationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = CharacterSet(charactersIn: textFieldAllowedCharacters).inverted
        let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        return (string == filtered)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case recipeNameTextField:
            textField.resignFirstResponder()
        case ingredientsVC.textFieldView.textField:
            self.ingredientsVC.textFieldView.secondaryTextField.becomeFirstResponder()
        case ingredientsVC.textFieldView.secondaryTextField:
            self.ingredientsVC.textFieldView.secondaryTextField.resignFirstResponder()
        case stepsVC.textFieldView.textField:
            self.stepsVC.textFieldView.textField.resignFirstResponder()
        case commentsVC.textFieldView.textField:
            self.commentsVC.textFieldView.textField.resignFirstResponder()
        default:
            break
        }
        return true
    }
}

extension RecipeCreationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageEdited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let imageEditedData = imageEdited.jpegData(compressionQuality: 0.4) else { return }
        viewModel.recipePicData.value = imageEditedData
        viewModel.downloadUrl.value = nil
        picturePicker.dismiss(animated: true, completion: nil)
    }
}

extension RecipeCreationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if yOffset <= -topViewMaxHeight {
            headerView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                make.trailing.leading.equalToSuperview()
                make.height.equalTo(self.topViewMaxHeight)
            }
            recipeImageView.layer.cornerRadius = 15
        } else if yOffset < -topViewMinHeight {
            headerView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                make.trailing.leading.equalToSuperview()
                make.height.equalTo(yOffset * -1)
            }
            recipeImageView.layer.cornerRadius = yOffset * (topViewMinHeight / topViewMaxHeight) * -5 / 15
            self.view.layoutIfNeeded()
        } else {
            headerView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                make.trailing.leading.equalToSuperview()
                make.height.equalTo(self.topViewMinHeight)
            }
            recipeImageView.layer.cornerRadius = 5
        }
        addImageButton.alpha = headerView.frame.height == topViewMaxHeight ? 1 : 0
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        var rectangle = self.view.frame
        rectangle.size.height -= keyboardFrame.height
        
        scrollView.contentInset = UIEdgeInsets(top: topViewMinHeight, left: 0, bottom: keyboardFrame.height, right: 0)
        
        // ScrollView Response
        var activeFieldYPosition: CGFloat = 0
        
        switch activeField {
        case recipeNameTextField:
            activeFieldYPosition = 0
        case ingredientsVC.textFieldView.textField, ingredientsVC.textFieldView.secondaryTextField:
            activeFieldYPosition = ingredientsContainer.frame.origin.y + ingredientsVC.listTableView.contentSize.height - 120
        case stepsVC.textFieldView.textField:
            activeFieldYPosition = stepsContainer.frame.origin.y +  stepsVC.listTableView.contentSize.height - 120
        case commentsVC.textFieldView.textField:
            activeFieldYPosition = commentsContainer.frame.origin.y + commentsVC.listTableView.contentSize.height - 120
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
            self.scrollView.setContentOffset(CGPoint(x: 0, y: activeFieldYPosition), animated: true)
        }
        
        self.view.addGestureRecognizer(self.tapGestureToHideKeyboard)
        
        if let activeField = activeField {
            scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        DispatchQueue.main.async {
            self.scrollView.contentInset = UIEdgeInsets(top: self.topViewMaxHeight, left: 0, bottom: self.bottomViewHeight, right: 0)
            self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -96), animated: true)
        }
        self.view.removeGestureRecognizer(self.tapGestureToHideKeyboard)
    }
}

//extension RecipeCreationViewControllerBis: UIGestureRecognizerDelegate {
//    private func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//        if touch.view?.isDescendant(of: self.ingredientsVC.listTableView) == true ||
//            touch.view?.isDescendant(of: self.stepsVC.listTableView) == true ||
//            touch.view?.isDescendant(of: self.commentsVC.listTableView) == true {
//            return false
//        }
//        return true
//    }
//}
