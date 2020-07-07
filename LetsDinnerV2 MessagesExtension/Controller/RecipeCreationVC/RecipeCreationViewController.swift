//
//  RecipeCreationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
import ReactiveSwift

protocol RecipeCreationVCDelegate: class {
    func recipeCreationVCDidTapDone()
}

protocol RecipeCreationVCUpdateDelegate: class {
    #warning("Will be Removed")
    func recipeCreationVCDidUpdateRecipe()
}

struct TemporaryIngredient {
    let name: String
    let amount: Double?
    let unit: String?
}

class RecipeCreationViewController: UIViewController  {
 
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var servingsStepper: UIStepper!
    
    // TextField Outlet
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!

    @IBOutlet weak var amountTextField: UITextField!
    //    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var stepTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    
    // Button
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var bottomEditButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addIngredientButton: UIButton!
    @IBOutlet weak var addCookingStepButton: UIButton!
    @IBOutlet weak var addCommentButton: UIButton!
    
    // View
    @IBOutlet weak var ingredientCellSeparator: UIView!
    @IBOutlet weak var stepCellSeparator: UIView!
    @IBOutlet weak var ingredientTableView: UITableView!
    @IBOutlet weak var stepTableView: UITableView!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var ingredientTextFieldView: UIView!
    @IBOutlet weak var stepTextFieldView: UIView!
    @IBOutlet weak var commentTextFieldView: UIView!
    
    // Constraints
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    // TableView Height Constraint
    @IBOutlet weak var stepTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTableViewHeightConstraint: NSLayoutConstraint!
    
    // TextField View Height Constraint
    @IBOutlet weak var ingredientTextFieldViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTextFieldViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextFieldViewHeightConstraint: NSLayoutConstraint!
    
    // TableView Leading Constraint
    @IBOutlet weak var ingredientTableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTableViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ingredientSectionView: UIView!
    @IBOutlet weak var stepSectionView: UIView!
    @IBOutlet weak var commentSectionView: UIView!
    
    private let realm = try! Realm()
    
    private let rowHeight : CGFloat = 66
    private let topViewMinHeight: CGFloat = 55
    private let topViewMaxHeight: CGFloat = 200

    // Image
    private let picturePicker = UIImagePickerController()
    private var recipeImage: UIImage?
    private var downloadUrl: String?
    private var imageState: ImageState = .addPic
    private var imageDeletedWhileEditing = false

    private var activeField: UITextField?

    weak var recipeCreationVCDelegate: RecipeCreationVCDelegate?
    
    // Data
    let customRecipe = CustomRecipe()
    
    private var temporaryIngredients = [LDIngredient]() {
        didSet {
            ingredientTableView.reloadData()
            updateTableViewHeightConstraint(tableView: ingredientTableView)
            
            self.updateRecipeIsEditedStatus()
        }
    }
    
    private var temporarySteps = [String]() {
        didSet {
            stepTableView.reloadData()
            stepTableView.layoutIfNeeded()
            updateTableViewHeightConstraint(tableView: stepTableView)
            viewWillLayoutSubviews()
            
            self.updateRecipeIsEditedStatus()
        }
    }
    
    private var temporaryComments = [String]() {
        didSet {
            commentTableView.reloadData()
            commentTableView.layoutIfNeeded()
            // BUG
            updateTableViewHeightConstraint(tableView: commentTableView)
            viewWillLayoutSubviews()
            
            self.updateRecipeIsEditedStatus()
        }
    }
    
    private var servings : Int = 2 {
        didSet {
            servingsLabel.text = String.localizedStringWithFormat(LabelStrings.servingLabel, String(servings))
            self.updateRecipeIsEditedStatus()
        }
    }
    
    // Custom Recipe
    var recipeToEdit: LDRecipe?
    var editingMode = false
    var viewExistingRecipe = false
    var editExistingRecipe = false
    var isAllowedToEditRecipe = false
    var isExistingRecipeAlreadyLoaded = false
    var isRecipeEdited = false
    
    private var selectedRowIngredient: Int?
    private var selectedRowStep: Int?
    private var selectedRowComment: Int?
    
    private lazy var createRecipeStartView = CreateRecipeStartView()
    
    // New Thing View
//    var newThingView: AddNewThingView?
//    var sectionNames = [CreateRecipeSections.name.rawValue, CreateRecipeSections.ingredient.rawValue, CreateRecipeSections.step.rawValue, CreateRecipeSections.comment.rawValue]
    
    var placeholderLabel = UILabel()
    var tapGestureToHideKeyboard = UITapGestureRecognizer()
    var swipeDownGestureToHideKeyBoard = UISwipeGestureRecognizer()
    
    private let loadingView = LDLoadingView()
    
    private let viewModel: RecipeCreationViewModel
    private let actionSheetManager = ActionSheetManager()
    
    init(viewModel: RecipeCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: VCNibs.recipeCreationViewController, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTableView()
        configureDelegate()
        configureGestureRecognizers()
        configureObservers()
        
        bindViewModel()

        if viewExistingRecipe {
            self.loadExistingCustomRecipe()
            self.updateViewExistingRecipeUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presentCreateRecipeWelcomeVCIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        super.viewWillLayoutSubviews()
//        updateTableViewHeightConstraint(tableView: stepsTableView)
    }
    
    private func bindViewModel() {
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
        
        self.viewModel.recipeUploadSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeResult { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case.success(()):
                self.recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.viewModel.recipeUpdateSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeResult { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case.success(()):
                self.recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.viewModel.deleteRecipeSignal
        .observe(on: UIScheduler())
        .take(duringLifetimeOf: self)
        .observeResult { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success():
                self.recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: Configure UI
    private func configureUI() {
        
        bottomView.isHidden = !isAllowedToEditRecipe
        
        recipeImageView.layer.cornerRadius = 15

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        servingsLabel.text = "For \(servings) people"
        servingsStepper.minimumValue = 2
        servingsStepper.maximumValue = 12
        servingsStepper.stepValue = 1
        servingsStepper.value = Double(servings)
        
//        commentsTextView.tintColor = Colors.highlightRed
//        commentsTextView.font = UIFont.systemFont(ofSize: 17)
//        commentsTextView.addSubview(placeholderLabel)

        placeholderLabel.text = LabelStrings.cookingTipsPlaceholder
        placeholderLabel.sizeToFit()
//        placeholderLabel.frame.origin = CGPoint(x: 5, y: (commentsTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.font = .systemFont(ofSize: 17)
//        placeholderLabel.isHidden = !commentsTextView.text.isEmpty
    }
    
    private func configureTableView() {
        ingredientTableView.registerCells(CellNibs.createRecipeIngredientCell)
        stepTableView.registerCells(CellNibs.createRecipeCookingStepCell)
        #warning("build his own cell later")
        commentTableView.registerCells(CellNibs.createRecipeCookingStepCell)

        ingredientTableView.isEditing = true
        ingredientTableView.allowsSelectionDuringEditing = false
        ingredientTableView.rowHeight = rowHeight
        ingredientTableViewHeightConstraint.constant = 0

        stepTableView.isEditing = true
        stepTableView.allowsSelectionDuringEditing = false
        stepTableViewHeightConstraint.constant = 0
        
        commentTableView.isEditing = true
        commentTableView.allowsSelectionDuringEditing = false
        commentTableViewHeightConstraint.constant = 0
    }
    
    private func configureDelegate() {
        recipeNameTextField.delegate = self
        ingredientTextField.delegate = self
        amountTextField.delegate = self
        stepTextField.delegate = self
        commentTextField.delegate = self
        
        ingredientTableView.dataSource = self
        ingredientTableView.delegate = self
        stepTableView.delegate = self
        stepTableView.dataSource = self
        commentTableView.dataSource = self
        commentTableView.delegate = self
        
        picturePicker.delegate = self
        scrollView.delegate = self

//        commentsTextView.delegate = self
    }
    
    private func configureNewThingView() {
//        newThingView = AddNewThingView(type: .createRecipe, sectionNames: sectionNames, selectedSection: nil)
//        newThingView?.addThingDelegate = self
//
//        addThingView.addSubview(newThingView!)
//
//        newThingView!.translatesAutoresizingMaskIntoConstraints = false
//        newThingView!.anchor(top: addThingView.topAnchor,
//                             leading: addThingView.leadingAnchor,
//                             bottom: addThingView.bottomAnchor,
//                             trailing: addThingView.trailingAnchor)
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    func presentCreateRecipeWelcomeVCIfNeeded() {
        if defaults.bool(forKey: Keys.createCustomRecipeWelcomeVCVisited) != true {
            let welcomeVC = RecipeCreationWelcomeViewController()
            welcomeVC.modalPresentationStyle = .overFullScreen
            self.present(welcomeVC, animated: true, completion: nil)
        }
    }

    private func configureGestureRecognizers() {
        // Should only tap on the view not on the keyboard
        tapGestureToHideKeyboard = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapGestureToHideKeyboard.delegate = self
        
//        swipeDownGestureToHideKeyBoard = UISwipeGestureRecognizer(target: newThingView, action: #selector(UIView.endEditing(_:)))
//        swipeDownGestureToHideKeyBoard.direction = .down
    }
    
    private func updateTableViewHeightConstraint(tableView: UITableView) {
        switch tableView {
        case ingredientTableView:
            ingredientTableViewHeightConstraint.constant = CGFloat(temporaryIngredients.count) * rowHeight
        case stepTableView:
            #warning("may need to be enhance the code")
            print(self.stepTableView.contentSize.height)
            stepTableViewHeightConstraint.constant = self.stepTableView.contentSize.height + 3
//            stepsTableViewHeightConstraint.constant = CGFloat(temporarySteps.count) * rowHeight
        case commentTableView:
            commentTableViewHeightConstraint.constant = self.commentTableView.contentSize.height + 3
        default:
            break
        }
        
        contentViewHeightConstraint.constant = 650 + ingredientTableViewHeightConstraint.constant + stepTableViewHeightConstraint.constant + commentTableViewHeightConstraint.constant + 100
    }
    
    // MARK: Edit Mode UI
    func updateViewExistingRecipeUI() {
        updateEditingModeUI(enterEditingMode: false)
    }
    
    private func updateEditingModeUI(enterEditingMode bool: Bool) {
        // TableViews
        [ingredientTableView, stepTableView, commentTableView].forEach {
            $0?.isEditing = bool
            $0?.allowsSelection = bool
            $0?.isUserInteractionEnabled = bool
        }
        
        // TextFields
        self.hideTextFieldView(!bool)
        recipeNameTextField.isEnabled = bool
//        commentsTextView.isEditable = bool
        
        // Other
        self.hideBottomView(bool)
        self.updateTableViewLeading(enterEditingMode: bool)
        self.addImageButton.isHidden = !bool
        servingsStepper.isHidden = !bool
        
        if viewExistingRecipe {
//            if commentsTextView.text.isEmpty {
//                if bool {
//                    placeholderLabel.text = "Any Tips and comment?"
//                    placeholderLabel.isHidden = false
//                }
//            } else {
//                placeholderLabel.text = nil
//                placeholderLabel.isHidden = true
//            }
        }
        bottomView.isHidden = !isAllowedToEditRecipe
    }
    
    private func hideTextFieldView(_ bool: Bool) {
        if bool {
            [ingredientTextFieldViewHeightConstraint, stepTextFieldViewHeightConstraint, commentTextFieldViewHeightConstraint].forEach {
                $0.constant = 0
            }
        } else {
            ingredientTextFieldViewHeightConstraint.constant = 66
            stepTextFieldViewHeightConstraint.constant = 44
            commentTextFieldViewHeightConstraint.constant = 44
        }
        
        ingredientTextFieldView.isHidden = bool
        stepTextFieldView.isHidden = bool
        commentTextFieldView.isHidden = bool
        self.view.layoutIfNeeded()
    }
    
    private func hideBottomView(_ bool: Bool) {
        bottomView.isHidden = bool
        bottomViewBottomConstraint.constant = bool ? -100 : 0
        self.view.layoutIfNeeded()
    }
    
    private func updateTableViewLeading(enterEditingMode bool: Bool) {
        ingredientTableViewLeadingConstraint.constant = bool ? 14 : 20
        stepTableViewLeadingConstraint.constant = bool ? 14 : 20
        commentTableViewLeadingConstraint.constant = bool ? 14 : 20

        ingredientTableView.separatorInset.left = bool ? 15 : 10
        stepTableView.separatorInset.left = bool ? 15 : 10
        commentTableView.separatorInset.left = bool ? 15 : 10
        
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Load Existing Custom Recipe
    private func loadExistingCustomRecipe() {
        
        guard let recipe = recipeToEdit else { return }
//        headerLabel.text = recipe.title
        if let downloadUrl = recipe.downloadUrl {
            recipeImageView.kf.indicatorType = .activity
            recipeImageView.kf.setImage(with: URL(string: downloadUrl), placeholder: Images.imagePlaceholderBig) { result in
                switch result {
                case .success:
                    self.addImageButton.setTitle(ButtonTitle.editImage, for: .normal)
                    self.imageState = .deleteOrModifyPic
                case .failure:
                    let alert = UIAlertController(title: AlertStrings.errorTitle, message: AlertStrings.retrieveImageErrorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: AlertStrings.okAction, style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        downloadUrl = recipe.downloadUrl
        recipeNameTextField.text = recipe.title
        servingsLabel.text = String.localizedStringWithFormat(LabelStrings.servingLabel, String(recipe.servings))
        servingsStepper.value = Double(recipe.servings)
        
        recipe.ingredients.forEach { customIngredient in
            let temporaryIngredient = LDIngredient(name: customIngredient.name,
                                                   amount: customIngredient.amount ?? nil,
                                                   unit: customIngredient.unit ?? nil)
            temporaryIngredients.append(temporaryIngredient)
        }
        
        recipe.cookingSteps.forEach { step in
            temporarySteps.append(step)
        }
        
//        if let comments = recipe.comments {
//            commentsTextView.text = comments
//        } else {
//            placeholderLabel.text = LabelStrings.noTipsAndComments
//        }
        
        self.isExistingRecipeAlreadyLoaded = true
    }
    
    private func presentImagePicker() {
        picturePicker.popoverPresentationController?.sourceView = addImageButton
        picturePicker.popoverPresentationController?.sourceRect = addImageButton.bounds
        picturePicker.sourceType = .photoLibrary
        picturePicker.allowsEditing = true
        present(picturePicker, animated: true, completion: nil)
    }
    
    // MARK: Present Action Sheet
    private func presentEditActionSheet() {
        let alert = actionSheetManager.presentEditActionSheet(
            sourceView: self.bottomEditButton,
            message: String.localizedStringWithFormat(AlertStrings.editRecipeActionSheetMessage, self.recipeToEdit?.title ?? ""),
            editActionCompletion: { _ in
                self.editingMode = true
                self.editExistingRecipe = true
                self.updateEditingModeUI(enterEditingMode: true)},
            deleteActionCompletion: { _ in
                guard let recipe = self.recipeToEdit else { return }
                self.viewModel.deleteRecipe(recipe)})
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentDoneActionSheet() {
        let alert = actionSheetManager.presentDoneActionSheet(
            sourceView: self.doneButton,
            message: AlertStrings.doneActionSheetMessage,
            saveActionCompletion: { _ in
                self.saveRecipe() },
            discardActionCompletion: { _ in
                self.dismiss(animated: true, completion: nil) })
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Functions
    private func addIngredient(name: String?, amountString: String?) {
        var unit = ""
        var amount = ""
        var ingredient: LDIngredient

        // Check if amountString have unit
        if var amountString = amountString {
            amountString = amountString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if amountString.hasWhiteSpace {
                let amountStringArray = amountString.split(separator: " ")
                amount = String(amountStringArray[0])
                
                for index in 1...amountStringArray.count - 1 {
                    unit += String(amountStringArray[index]) + " "
                }
            } else {
                amount = amountString
            }
        }
           
        if let name = name {
            if name.isEmpty {
                addIngredientButton.shake()
                return
            } else {
                let amountAsDouble = amount.doubleValue
                
                if amountAsDouble != 0 && !unit.isEmpty {
                    ingredient = LDIngredient(name: name, amount: amountAsDouble, unit: unit)
                } else if amountAsDouble != 0 && unit.isEmpty {
                    ingredient = LDIngredient(name: name, amount: amountAsDouble, unit: nil)
                } else {
                    ingredient = LDIngredient(name: name, amount: nil, unit: nil)
                }

                if let row = selectedRowIngredient {
                    temporaryIngredients.remove(at: row)
                    temporaryIngredients.insert(ingredient, at: row)
                    selectedRowIngredient = nil
                } else {
                    temporaryIngredients.append(ingredient)
                }
            }
        }
        
        ingredientTextField.text = ""
        amountTextField.text = ""
    }
        
    private func addCookingStep(step: String?) {
        if let step = step {
            if step.isEmpty {
                stepTextField.shake()
                return
            } else {
                if let row = selectedRowStep {
                    temporarySteps.remove(at: row)
                    temporarySteps.insert(step, at: row)
                    selectedRowStep = nil
                } else {
                    temporarySteps.append(step)
                }
            }
        }
        stepTextField.text = ""
    }
    
    private func addComment(comment: String?) {
//        if let comment = comment {
//            commentsTextView.text = comment
//            placeholderLabel.isHidden = !commentsTextView.text.isEmpty
//        }
    }
    
    private func verifyInformation() -> Bool {
        if let recipeName = recipeNameTextField.text {
            if recipeName.isEmpty {
                recipeNameTextField.shake()
                return false
            } else {
                return true
            }
        }
        if recipeImage == nil {
            // setup an default image
            recipeImage = Images.emptyPlate
        }
        return false
    }
    
    private func shakeEmptyTextFields() {
        ingredientTextField.shake()
        stepTextField.shake()
    }
    
    private func allTextFieldsAreEmpty() -> Bool {
        if recipeNameTextField.text == "" && commentTextField.text == "" && ingredientTextField.text == "" && amountTextField.text == "" && stepTextField.text == "" {
            return true
        }
        return false
    }
    
    private func updateRecipeIsEditedStatus() {
        if viewExistingRecipe {
            if isExistingRecipeAlreadyLoaded {
                isRecipeEdited = true
            }
        } else {
            isRecipeEdited = true
        }
    }
    
    // MARK: Data write in Realm
//    private func saveRecipeToRealm(completion: @escaping (Result<Bool, Error>) -> Void) {
//        do {
//            try self.realm.write {
//                let customIngredients = List<CustomIngredient>()
////                if let recipeImage = recipeImageView.image {
////                    customRecipe.imageData = recipeImage.pngData()
////                }
//                if let recipeTitle = recipeNameTextField.text {
//                    customRecipe.title = recipeTitle
//                }
//                if let downloadUrl = self.downloadUrl {
//                    customRecipe.downloadUrl = downloadUrl
//                }
//                customRecipe.servings = servings
//                temporaryIngredients.forEach { temporaryIngredient in
//                    let customIngredient = CustomIngredient()
//                    customIngredient.name = temporaryIngredient.name
//                    if let amount = temporaryIngredient.amount {
//                        customIngredient.amount.value = amount
//                    }
//                    if let unit = temporaryIngredient.unit {
//                       customIngredient.unit = unit
//                    }
//                    customIngredients.append(customIngredient)
//                }
//                customRecipe.ingredients = customIngredients
//                if let comments = commentsTextView.text {
//                    customRecipe.comments = comments
//                }
//                let cookingSteps = List<String>()
//                temporarySteps.forEach { step in
//                    cookingSteps.append(step)
//                }
//                customRecipe.cookingSteps = cookingSteps
//                realm.add(customRecipe)
//            }
//            DispatchQueue.main.async {
//                completion(.success(true))
//            }
//        } catch {
//            print(error)
//
//            DispatchQueue.main.async {
//                completion(.failure(error))
//            }
//        }
//    }
    
    private func updateRecipeInRealm(recipe: CustomRecipe, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            try self.realm.write {
                let customIngredients = List<CustomIngredient>()
                if let recipeTitle = recipeNameTextField.text {
                    recipe.title = recipeTitle
                }
//                if let downloadUrl = self.downloadUrl {
//                    recipe.downloadUrl = downloadUrl
//                } else {
//                    recipe.downloadUrl = nil
//                }
                recipe.downloadUrl = downloadUrl
                recipe.servings = servings
                temporaryIngredients.forEach { temporaryIngredient in
                    let customIngredient = CustomIngredient()
                    customIngredient.name = temporaryIngredient.name
                    if let amount = temporaryIngredient.amount {
                        customIngredient.amount.value = amount
                    }
                    if let unit = temporaryIngredient.unit {
                        customIngredient.unit = unit
                    }
                    customIngredients.append(customIngredient)
                }
                recipe.ingredients.removeAll()
                recipe.ingredients.append(objectsIn: customIngredients)
                if let comments = commentsTextView.text {
                    recipe.comments = comments
                }
                let cookingSteps = List<String>()
                temporarySteps.forEach { step in
                    cookingSteps.append(step)
                }
                recipe.cookingSteps.removeAll()
                recipe.cookingSteps.append(objectsIn: cookingSteps)
            }
            DispatchQueue.main.async {
                completion(.success(true))
            }
        } catch {
            print(error)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Did Tap Buttons
    @IBAction func didTapDoneButton(_ sender: Any) {
        
        view.endEditing(true)
        
        guard editingMode else {
            self.recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if editExistingRecipe {
            
            // Editing Existing Recipe
            if isRecipeEdited {
                self.presentDoneActionSheet()
            } else {
                self.dismiss(animated: true, completion: nil)
            }

        } else {
            
            // Creating New Recipe
            if isRecipeEdited || !allTextFieldsAreEmpty() {
                self.presentDoneActionSheet()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
            
    
    }
    
    func saveRecipe() {
//        if verifyInformation() {
//                    
//            if editExistingRecipe {
//                guard let recipeToEdit = recipeToEdit else { return }
//                updateRecipeInRealm(recipe: recipeToEdit) { [weak self] result in
//                    switch result {
//                    case .success:
//                       // pass the tasks has been edited and the recipe is selected
//                        self?.recipeCreationVCUpdateDelegate?.recipeCreationVCDidUpdateRecipe()
//                        self?.dismiss(animated: true, completion: nil)
//                    case .failure:
//                        // To modify
//                        let alert = UIAlertController(title: "Error", message: "Error while updating your recipe", preferredStyle: .alert)
//                        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
//                        alert.addAction(action)
//                        self?.present(alert, animated: true, completion: nil)
//                    }
//                }
//            } else {
//                        saveRecipeToRealm { [weak self] result in
//                            guard let self = self else { return }
//                            switch result {
//                            case .success:
//                                self.recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
//                                self.dismiss(animated: true, completion: nil)
//                            case .failure:
//                                // To modify
//                                let alert = UIAlertController(title: "Error", message: "Error while saving your recipe", preferredStyle: .alert)
//                                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
//                                alert.addAction(action)
//                                self.present(alert, animated: true, completion: nil)
//                            }
//                        }
//                    }
//                    
//                }
        
        if verifyInformation() {
//            let comments = commentsTextView.text.isEmpty ? nil : commentsTextView.text
            let comments = ""
            
            let recipe = LDRecipe(title: self.recipeNameTextField.text!,
                                  servings: self.servings,
                                  downloadUrl: self.downloadUrl,
                                  cookingSteps: self.temporarySteps,
                                  comments: comments,
                                  ingredients: self.temporaryIngredients)
            
            if editExistingRecipe {
                guard let recipeToEdit = recipeToEdit else { return }
                viewModel.updateRecipe(currentRecipe: recipeToEdit, newRecipe: recipe)
            } else {
                viewModel.saveRecipe(recipe)
            }
        }
    }

    @IBAction func didTapStepper(_ sender: UIStepper) {
        servings = Int(sender.value)
    }
    
    @IBAction func didTapAddIngredientButton(_ sender: UIButton) {
        self.addIngredient(name: ingredientTextField.text,
                           amountString: amountTextField.text)
        ingredientTextField.becomeFirstResponder()
    }
    
    @IBAction func didTapAddStepButton(_ sender: UIButton) {
        if let step = stepTextField.text {
            if step.isEmpty {
                addCookingStepButton.shake()
                return
            } else {
                if let row = selectedRowStep {
                    temporarySteps.remove(at: row)
                    temporarySteps.insert(step, at: row)
                    selectedRowStep = nil
                } else {
                    temporarySteps.append(step)
                }
            }
        }
        stepTextField.text = ""
        stepTextField.becomeFirstResponder()
    }
    
    @IBAction func didTapAddCommentButton(_ sender: UIButton) {
        if let comment = commentTextField.text {
            if comment.isEmpty {
                addCommentButton.shake()
                return
            } else {
                if let row = selectedRowComment {
                    temporaryComments.remove(at: row)
                    temporaryComments.insert(comment, at: row)
                    selectedRowComment = nil
                } else {
                    temporaryComments.append(comment)
                }
            }
        }
        commentTextField.text = nil
        commentTextField.becomeFirstResponder()
    }
    
        
    @IBAction func didTapAddImage(_ sender: UIButton) {
        switch imageState {
        case .addPic:
            presentImagePicker()
        case .deleteOrModifyPic:
            let alert = UIAlertController(title: "", message: AlertStrings.changeImageActionSheetMessage, preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = addImageButton
            alert.popoverPresentationController?.sourceRect = addImageButton.bounds
            let cancel = UIAlertAction(title: AlertStrings.cancel, style: .cancel, handler: nil)
            let change = UIAlertAction(title: AlertStrings.change, style: .default) { action in
                self.presentImagePicker()
            }
            let delete = UIAlertAction(title: AlertStrings.delete, style: .destructive) { action in
                self.recipeImageView.image = Images.imagePlaceholderBig
                self.addImageButton.setTitle(ButtonTitle.addImage, for: .normal)
                self.imageState = .addPic
                self.downloadUrl = nil
            }
            alert.addAction(cancel)
            alert.addAction(change)
            alert.addAction(delete)
            self.present(alert, animated: true, completion: nil)
        }
        
        self.isRecipeEdited = true
    }
    
    @IBAction func didTapBottomAdd(_ sender: Any) {
//        self.removeStartView()
        
//        if !editingMode {
//            newThingView?.mainTextField.becomeFirstResponder()
//            newThingView?.updateUI(type: .createRecipe, selectedSection: "Name")
//            bottomEditButton.isHidden = false
//        }
    }
    
    @IBAction func didTapBottomEditButton(_ sender: Any) {
        if self.editingMode {
        } else {
            self.presentEditActionSheet()
        }
    }

}

// MARK: TextFieldDelegate / TextViewDelegate
extension RecipeCreationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        
        // Pass to AddThingView
//        DispatchQueue.main.async {
//
//            switch textField {
//            case self.recipeNameTextField:
//                self.newThingView?.selectedSection = CreateRecipeSections.name.rawValue
//
//            case self.ingredientTextField:
//
//                self.newThingView?.selectedSection = CreateRecipeSections.ingredient.rawValue
//
//
//            case self.stepTextField:
//                self.newThingView?.selectedSection = CreateRecipeSections.step.rawValue
//            default:
//                break
//            }
//
//            self.newThingView?.mainTextField.becomeFirstResponder()
//        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case recipeNameTextField:
            textField.resignFirstResponder()
        case ingredientTextField:
            amountTextField.becomeFirstResponder()
        case amountTextField:
            self.ingredientTextField.resignFirstResponder()
        case stepTextField:
            self.stepTextField.becomeFirstResponder()
        case commentTextField:
            self.commentTextField.becomeFirstResponder()
        default:
            break
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateRecipeIsEditedStatus()
        
        let cs = CharacterSet(charactersIn: textFieldAllowedCharacters).inverted
        let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        return (string == filtered)
    }
}

extension RecipeCreationViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView == commentsTextView {
//            newThingView?.mainTextField.becomeFirstResponder()
//            newThingView?.selectedSection = CreateRecipeSections.comment.rawValue
//        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//       commentsTextView.resignFirstResponder()
       return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
}

extension RecipeCreationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        recipeImageView.image = imageOriginal
        recipeImage = imageOriginal
        
        guard let imageEdited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        recipeImageView.image = imageEdited
        recipeImage = imageEdited
        
        imageState = .deleteOrModifyPic
        addImageButton.setTitle(ButtonTitle.editImage, for: .normal)
        
        picturePicker.dismiss(animated: true, completion: nil)
        
        if let recipeImage = recipeImage {
            doneButton.isHidden = true
            activityIndicator.startAnimating()
            
            ImageHelper.shared.saveRecipePicToFirebase(recipeImage, id: customRecipe.id) { [weak self] result in
                self?.doneButton.isHidden = false
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let url):
                    self?.downloadUrl = url
                case .failure:
                    let alert = UIAlertController(title: AlertStrings.errorTitle, message: AlertStrings.saveImageErrorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: AlertStrings.okAction, style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    self?.recipeImageView.image = Images.imagePlaceholderBig
                }
            }
        }
        
        
    }
}

// MARK: TableView Delegate
extension RecipeCreationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case ingredientTableView:
            return temporaryIngredients.count
        case stepTableView:
            return temporarySteps.count
        case commentTableView:
            return temporaryComments.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        switch tableView {
        case ingredientTableView:
            
            let ingredientCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.createRecipeIngredientCell, for: indexPath) as! CreateRecipeIngredientCell
            
            let ingredient = temporaryIngredients[indexPath.row]
            ingredientCell.configureCell(ingredient: ingredient)
        
            return ingredientCell
        case stepTableView:
            
            let stepCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.createRecipeCookingStepCell, for: indexPath) as! CreateRecipeCookingStepCell
            
            let step = temporarySteps[indexPath.row]
            stepCell.configureCell(stepDetail: step, stepNumber: indexPath.row + 1)

            return stepCell
        case commentTableView:
            let commentCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.createRecipeCookingStepCell, for: indexPath) as! CreateRecipeCookingStepCell
            
            let step = temporaryComments[indexPath.row]
            commentCell.configureCell(stepDetail: step, stepNumber: indexPath.row + 100)
            
            return commentCell

        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            switch tableView {
            case ingredientTableView:
                temporaryIngredients.remove(at: indexPath.row)
            case stepTableView:
                temporarySteps.remove(at: indexPath.row)
            case commentTableView:
                temporaryComments.remove(at: indexPath.row)
            default:
                break
            }
        }
    }
    
     func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch tableView {
        case ingredientTableView:
            let movedObject = temporaryIngredients[sourceIndexPath.row]
            temporaryIngredients.remove(at: sourceIndexPath.row)
            temporaryIngredients.insert(movedObject, at: destinationIndexPath.row)
        case stepTableView:
            let movedObject = temporarySteps[sourceIndexPath.row]
            temporarySteps.remove(at: sourceIndexPath.row)
            temporarySteps.insert(movedObject, at: destinationIndexPath.row)
        case commentTableView:
            let movedObject = temporaryComments[sourceIndexPath.row]
            temporaryComments.remove(at: sourceIndexPath.row)
            temporaryComments.insert(movedObject, at: destinationIndexPath.row)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if editingMode {
//            switch tableView {
//
//            case ingredientsTableView:
//                selectedRowIngredient = indexPath.row
//                let selectedIngredient = temporaryIngredients[indexPath.row]
//
//                // pop up at the addthingview
//                sendDataToNewThingView(selectedItem: selectedIngredient)
//
//            case stepsTableView:
//                selectedRowStep = indexPath.row
//                let selectedStep = temporarySteps[indexPath.row]
//
//                sendDataToNewThingView(selectedItem: selectedStep)
//
//            default:
//                break
//            }
//        }
    }
    
    private func sendDataToNewThingView(selectedItem: Any) {
        
//        if selectedItem is TemporaryIngredient {
//            let selectedIngredient = selectedItem as! TemporaryIngredient
//            newThingView?.selectedSection = CreateRecipeSections.ingredient.rawValue
//            newThingView?.mainTextField.becomeFirstResponder()
//            newThingView?.mainTextField.text = selectedIngredient.name
//
////            ingredientTextField.text = selectedIngredient.name
//
//            if let amount = selectedIngredient.amount {
////                amountTextField.text = String(amount)
//                newThingView?.amountTextField.text = String(amount)
//            }
//            if let unit = selectedIngredient.unit {
////                unitTextField.text = unit
//                newThingView?.unitTextField.text = unit
//            }
//        } else if selectedItem is String {
//            let selectedStep = selectedItem as! String
//            newThingView?.selectedSection = CreateRecipeSections.step.rawValue
//            newThingView?.mainTextField.becomeFirstResponder()
//            newThingView?.mainTextField.text = selectedStep
//        }
            
    }
}

// MARK: ScrollView Delegate

extension RecipeCreationViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
//        print(yOffset)
        
        if yOffset <= -topViewMaxHeight {
            headerViewHeightConstraint.constant = self.topViewMaxHeight
            recipeImageView.layer.cornerRadius = 15
            
        } else if yOffset < -topViewMinHeight {
            headerViewHeightConstraint.constant = yOffset * -1
            recipeImageView.layer.cornerRadius = yOffset * (topViewMinHeight / topViewMaxHeight) * -5 / 15
            self.view.layoutIfNeeded()
             
        } else {
            headerViewHeightConstraint.constant = topViewMinHeight
            recipeImageView.layer.cornerRadius = 5
        }
        
        addImageButton.alpha = (headerViewHeightConstraint.constant == topViewMaxHeight) ? 1 : 0
 
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        var rectangle = self.view.frame
        rectangle.size.height -= keyboardFrame.height
        
        scrollView.contentInset = UIEdgeInsets(top: topViewMinHeight,
        left: 0,
        bottom: keyboardFrame.height - topViewMinHeight,
        right: 0)
        
        // ScrollView Response
        #warning("will improve calculation (after Finalizing the design)")
        var activeFieldYPosition: CGFloat = 0
        
        switch activeField {
        case recipeNameTextField:
            activeFieldYPosition = 0
        case ingredientTextField, amountTextField:
            activeFieldYPosition = ingredientSectionView.frame.origin.y + ingredientTableViewHeightConstraint.constant
        case stepTextField:
            activeFieldYPosition = stepSectionView.frame.origin.y +  stepTableViewHeightConstraint.constant
        case commentTextField:
            activeFieldYPosition = commentSectionView.frame.origin.y + commentTableViewHeightConstraint.constant
        default: break// For Comment Section
        }
        
        DispatchQueue.main.async {
            self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
            self.scrollView.setContentOffset(CGPoint(x: 0, y: activeFieldYPosition - self.topViewMinHeight), animated: true)
        }
        
        self.view.addGestureRecognizer(self.tapGestureToHideKeyboard)
 
//        if let activeField = activeField {
//            scrollView.scrollRectToVisible(activeField.frame, animated: true)
//            if !rectangle.contains(activeField.frame.origin) {
//
//            }
//        }
        
//        if activeField == nil {
//            scrollView.scrollRectToVisible(commentsTextView.frame, animated: true)
//        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        DispatchQueue.main.async {
            self.scrollView.contentInset = UIEdgeInsets(top: self.topViewMaxHeight, left: 0, bottom: 0, right: 0)
            self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -96), animated: true)
        }
        
//        showAddThingView(false, keyboardHeight: nil)
        self.view.removeGestureRecognizer(self.tapGestureToHideKeyboard)
        self.deselectSelectedRow()
    }
    
//    private func showAddThingView(_ bool: Bool, keyboardHeight: CGFloat?) {
//        if bool {
//
//            guard let keyboardHeight = keyboardHeight else {return}
//
//            UIView.animate(withDuration: 1) {
//                self.addThingViewBottomConstraint.constant = keyboardHeight
//
//                if UIDevice.current.userInterfaceIdiom == .pad {
//                    self.addThingViewBottomConstraint.constant += 20
//                }
//
//            }
//
//            self.view.addGestureRecognizer(self.tapGestureToHideKeyboard)
//            self.view.addGestureRecognizer(self.swipeDownGestureToHideKeyBoard)
//
//        } else {
//
//            UIView.animate(withDuration: 1) {
//                self.addThingViewBottomConstraint.constant = -100
//
//                if UIDevice.current.userInterfaceIdiom == .pad {
//                    self.addThingViewBottomConstraint.constant -= 20
//                }
//            }
//
//           self.view.removeGestureRecognizer(self.tapGestureToHideKeyboard)
//           self.view.removeGestureRecognizer(self.swipeDownGestureToHideKeyBoard)
//        }
//
//        self.view.layoutIfNeeded()
//
//    }
    
}


extension RecipeCreationViewController: AddThingDelegate {
    
    // Pass thing from AddThingView
    func doneEditThing(selectedSection: String?, item: String?, amount: String?, unit: String?) {
//        switch selectedSection {
//        case CreateRecipeSections.name.rawValue:
//            recipeNameTextField.text = mainContent
//        case CreateRecipeSections.ingredient.rawValue:
//            addIngredient(name: mainContent, amount: amount, unit: unit)
//        case CreateRecipeSections.step.rawValue:
//            addCookingStep(step: mainContent)
//        case CreateRecipeSections.comment.rawValue:
//            addComment(comment: mainContent)
//        default:
//            break
//        }
//
//        self.deselectSelectedRow()
        
    }
    
    private func deselectSelectedRow() {
//        ingredientsTableView.deselectSelectedRow(animated: true)
//        stepsTableView.deselectSelectedRow(animated: true)
    }
}

extension RecipeCreationViewController: UIGestureRecognizerDelegate {
    // To prevent touch in "Add Thing" View
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if touch.view!.isDescendant(of: addThingView) {
//            return false
//        }
//        return true
//    }
}
