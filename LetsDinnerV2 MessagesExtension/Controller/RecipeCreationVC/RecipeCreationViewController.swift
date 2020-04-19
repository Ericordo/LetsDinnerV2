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

protocol RecipeCreationVCDelegate: class {
    func recipeCreationVCDidTapDone()
}

protocol RecipeCreationVCUpdateDelegate: class {
    func recipeCreationVCDidUpdateRecipe()
}

struct TemporaryIngredient {
    let name: String
    let amount: Double?
    let unit: String?
}

enum CreateRecipeSections: String {
    case name = "Name"
    case ingredient = "Ingredient"
    case step = "Cooking Step"
    case comment = "Comment"
}

class RecipeCreationViewController: UIViewController  {
 

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var servingsStepper: UIStepper!
    @IBOutlet weak var bottomAddButton: UIButton!
    @IBOutlet weak var bottomEditButton: UIButton!
    
    // TextField Outlet
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var stepTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    
    // View
    @IBOutlet weak var ingredientCellSeparator: UIView!
    @IBOutlet weak var stepCellSeparator: UIView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var addThingView: UIView!
    
    // Constraint
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addThingViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTextFieldHeightConstraint: NSLayoutConstraint!
    
    private let realm = try! Realm()
    
    private let rowHeight : CGFloat = 44
    private let topViewMinHeight: CGFloat = 55
    private let topViewMaxHeight: CGFloat = 200
    private lazy var bottomEdgeInset: CGFloat =  scrollView.contentSize.height - scrollView.bounds.size.height

    // Image
    private let picturePicker = UIImagePickerController()
    private var recipeImage: UIImage?
    private var downloadUrl: String?
    private var imageState : ImageState = .addPic
    private var imageDeletedWhileEditing = false

    private var activeField: UITextField?
    
    let customRecipe = CustomRecipe()
    
    weak var recipeCreationVCDelegate: RecipeCreationVCDelegate?
    weak var recipeCreationVCUpdateDelegate: RecipeCreationVCUpdateDelegate?
    
    private var temporaryIngredients = [TemporaryIngredient]() {
        didSet {
            ingredientsTableView.reloadData()
            updateTableViewHeightConstraint(tableView: ingredientsTableView)
            hideTextField(tableView: ingredientsTableView)
        }
    }
    
    private var temporarySteps = [String]() {
        didSet {
            stepsTableView.reloadData()
            updateTableViewHeightConstraint(tableView: stepsTableView)
            hideTextField(tableView: stepsTableView)
        }
    }
    
    private var servings : Int = 2 {
           didSet {
               servingsLabel.text = "For \(servings) people"
           }
       }
    
    // Custom Recipe
    var recipeToEdit: CustomRecipe?
    var editingMode = false {
        didSet {
            toggleEditButton()
        }
    }
    var editExistRecipe = false
    
    private var selectedRowIngredient: Int?
    private var selectedRowStep: Int?
    
    private var createRecipeStartView = CreateRecipeStartView()
    
    // New Thing View
    var newThingView: AddNewThingView?
    var sectionNames = [CreateRecipeSections.name.rawValue, CreateRecipeSections.ingredient.rawValue, CreateRecipeSections.step.rawValue, CreateRecipeSections.comment.rawValue]
    
    var placeholderLabel = UILabel()
    var tapGestureToHideKeyboard = UITapGestureRecognizer()
    var swipeDownGestureToHideKeyBoard = UISwipeGestureRecognizer()
    
    
    // MARK: ViewDidLaod
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureUI()
        configureTableView()
        configureDelegate()
        configureNewThingView()
        configureGestureRecognizers()
        configureObservers()
                
        if editExistRecipe {
            bottomEditButton.isHidden = false
            loadExistingCustomRecipe()
        }

    }
    
    // MARK: Configuration UI
    private func configureUI() {
        
        if !editExistRecipe {
            self.addStartView()
        }
        
        bottomEditButton.isHidden = true
        
        addThingView.addShadow()
        
        recipeImageView.layer.cornerRadius = 15
    

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        servingsLabel.text = "For \(servings) people"
        servingsStepper.minimumValue = 2
        servingsStepper.maximumValue = 12
        servingsStepper.stepValue = 1
        servingsStepper.value = Double(servings)
        
        commentsTextView.tintColor = Colors.highlightRed
        commentsTextView.font = UIFont.systemFont(ofSize: 17)
        commentsTextView.addSubview(placeholderLabel)

        placeholderLabel.text = LabelStrings.cookingTipsPlaceholder
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (commentsTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.placeholderText
        placeholderLabel.font = UIFont.systemFont(ofSize: 17)
        placeholderLabel.isHidden = !commentsTextView.text.isEmpty
    }
    
    private func configureTableView() {
        ingredientsTableView.register(UINib(nibName: CellNibs.ingredientCell, bundle: nil), forCellReuseIdentifier: CellNibs.ingredientCell)
        stepsTableView.register(UINib(nibName: CellNibs.ingredientCell, bundle: nil), forCellReuseIdentifier: CellNibs.ingredientCell)
        
        ingredientsTableView.isEditing = false
        ingredientsTableView.allowsSelectionDuringEditing = false
        ingredientsTableView.rowHeight = rowHeight
        ingredientsTableViewHeightConstraint.constant = 0

        stepsTableView.isEditing = false
        stepsTableView.allowsSelectionDuringEditing = false
        stepsTableView.rowHeight = rowHeight
        stepsTableViewHeightConstraint.constant = 0
    }
    
    private func configureDelegate() {
        recipeNameTextField.delegate = self
        ingredientTextField.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.delegate = self
        picturePicker.delegate = self
        scrollView.delegate = self
        stepTextField.delegate = self
        commentsTextView.delegate = self
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
    }
    
    private func configureNewThingView() {
        newThingView = AddNewThingView(type: .createRecipe, sectionNames: sectionNames, selectedSection: nil)
        newThingView?.addThingDelegate = self
    
        addThingView.addSubview(newThingView!)
        
        newThingView!.translatesAutoresizingMaskIntoConstraints = false
        newThingView!.anchor(top: addThingView.topAnchor,
                             leading: addThingView.leadingAnchor,
                             bottom: addThingView.bottomAnchor,
                             trailing: addThingView.trailingAnchor)
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }

    private func addStartView() {
        self.view.addSubview(createRecipeStartView)
        
        createRecipeStartView.translatesAutoresizingMaskIntoConstraints = false
        createRecipeStartView.anchor(top: headerView.bottomAnchor, leading: self.view.leadingAnchor, bottom: bottomView.topAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    private func removeStartView() {
        createRecipeStartView.removeFromSuperview()
    }

    private func configureGestureRecognizers() {
        // Should only tap on the view not on the keyboard
        tapGestureToHideKeyboard = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapGestureToHideKeyboard.delegate = self
        
        swipeDownGestureToHideKeyBoard = UISwipeGestureRecognizer(target: newThingView, action: #selector(UIView.endEditing(_:)))
        swipeDownGestureToHideKeyBoard.direction = .down
        
    }
    
    private func updateTableViewHeightConstraint(tableView: UITableView) {
        switch tableView {
        case ingredientsTableView:
            ingredientsTableViewHeightConstraint.constant = CGFloat(temporaryIngredients.count) * rowHeight
        case stepsTableView:
            stepsTableViewHeightConstraint.constant = CGFloat(temporarySteps.count) * rowHeight
        default:
            break
        }
        
        contentViewHeightConstraint.constant = 600 + ingredientsTableViewHeightConstraint.constant + stepsTableViewHeightConstraint.constant
    }
    
    private func hideTextField(tableView: UITableView) {
        switch tableView {
        case ingredientsTableView:
            ingredientTextFieldHeightConstraint.constant = (temporaryIngredients.isEmpty) ? 44 : 0
            ingredientCellSeparator.isHidden = (temporaryIngredients.isEmpty) ? false : true
        case stepsTableView:
            stepTextFieldHeightConstraint.constant = (temporarySteps.isEmpty) ? 44 : 0
            stepCellSeparator.isHidden = (temporarySteps.isEmpty) ? false : true
        default:
            break
        }
        self.view.layoutIfNeeded()

    }
    
    
    
    // MARK: Edit Mode UI
    private func configureEditMode(_ bool: Bool) {
        ingredientsTableView.isEditing = bool
        stepsTableView.isEditing = bool
    }
    
    private func loadExistingCustomRecipe() {
        
        guard let recipe = recipeToEdit else { return }
//        headerLabel.text = recipe.title
        if let downloadUrl = recipe.downloadUrl {
            recipeImageView.kf.indicatorType = .activity
            recipeImageView.kf.setImage(with: URL(string: downloadUrl), placeholder: UIImage(named: "imagePlaceholderBig.png")) { result in
                switch result {
                case .success:
                    self.addImageButton.setTitle("Edit image", for: .normal)
                    self.imageState = .deleteOrModifyPic
                case .failure:
                    let alert = UIAlertController(title: "Error while retrieving image", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        downloadUrl = recipe.downloadUrl
        recipeNameTextField.text = recipe.title
        servingsLabel.text = "For \(recipe.servings) people"
        servingsStepper.value = Double(recipe.servings)
        
        recipe.ingredients.forEach { customIngredient in
            let temporaryIngredient = TemporaryIngredient(name: customIngredient.name, amount: customIngredient.amount.value ?? 0, unit: customIngredient.unit ?? "")
            temporaryIngredients.append(temporaryIngredient)
        }
        
        recipe.cookingSteps.forEach { step in
            temporarySteps.append(step)
        }
        
        if let comments = recipe.comments {
            commentsTextView.text = comments
        }
        placeholderLabel.isHidden = !commentsTextView.text.isEmpty
        
        
    }
    
    private func presentImagePicker() {
        picturePicker.popoverPresentationController?.sourceView = addImageButton
        picturePicker.popoverPresentationController?.sourceRect = addImageButton.bounds
        picturePicker.sourceType = .photoLibrary
        picturePicker.allowsEditing = true
        present(picturePicker, animated: true, completion: nil)
    }
    
    private func presentDoneActionSheet() {
        let alert = UIAlertController(title: "", message: "Save or Discard your changes?", preferredStyle: .actionSheet)

        let saveAction = UIAlertAction(title: "Save", style: .default) {
            _ in self.saveRecipe()
        }
        let discardAction = UIAlertAction(title: "Discard", style: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        alert.addAction(discardAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Functions
    private func toggleEditButton() {
       if editingMode {
           bottomEditButton.setImage(UIImage(named: "editButton.png"), for: .normal)
            configureEditMode(true)
//           self.loadExistingCustomRecipe()
           
       } else {
           bottomEditButton.setImage(UIImage(named: "editButtonOutlined.png"), for: .normal)
            configureEditMode(false)

       }
   }
    
    private func addIngredient(name: String?, amount: String?, unit: String?) {
        var ingredient: TemporaryIngredient
        if let name = name, let amount = amount, let unit = unit {
            if name.isEmpty {
//                addButton.shake()
                return
            } else {
                if !amount.isEmpty && !unit.isEmpty {
                    ingredient = TemporaryIngredient(name: name, amount: amount.doubleValue, unit: unit)
                } else if !amount.isEmpty && unit.isEmpty {
                    ingredient = TemporaryIngredient(name: name, amount: amount.doubleValue, unit: nil)
                } else {
                    ingredient = TemporaryIngredient(name: name, amount: nil, unit: nil)
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
    //        amountTextField.text = ""
    //        unitTextField.text = ""

    }
        
    private func addCookingStep(step: String?) {
        if let step = step {
            if step.isEmpty {
//                        addStepButton.shake()
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
        if let comment = comment {
            commentsTextView.text = comment
            placeholderLabel.isHidden = !commentsTextView.text.isEmpty
        }
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
            recipeImage = createDefaultImage()
        }
        return false
    }
    
    private func createDefaultImage() -> UIImage {
        let imageName = "emptyPlate"
        let image = UIImage(named: imageName)
        return image!
    }
    
    
    // MARK: Data write in Realm
    private func saveRecipeToRealm(completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            try self.realm.write {
                let customIngredients = List<CustomIngredient>()
//                if let recipeImage = recipeImageView.image {
//                    customRecipe.imageData = recipeImage.pngData()
//                }
                if let recipeTitle = recipeNameTextField.text {
                    customRecipe.title = recipeTitle
                }
                if let downloadUrl = self.downloadUrl {
                    customRecipe.downloadUrl = downloadUrl
                }
                customRecipe.servings = servings
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
                customRecipe.ingredients = customIngredients
                if let comments = commentsTextView.text {
                    customRecipe.comments = comments
                }
                let cookingSteps = List<String>()
                temporarySteps.forEach { step in
                    cookingSteps.append(step)
                }
                customRecipe.cookingSteps = cookingSteps
                realm.add(customRecipe)
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
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapDone(_ sender: Any) {
        self.presentDoneActionSheet()

    }
    
    func saveRecipe() {
        if verifyInformation() {
                    
            if editExistRecipe {
                guard let recipeToEdit = recipeToEdit else { return }
                updateRecipeInRealm(recipe: recipeToEdit) { [weak self] result in
                    switch result {
                    case .success:
                       // pass the tasks has been edited and the recipe is selected
                        self?.recipeCreationVCUpdateDelegate?.recipeCreationVCDidUpdateRecipe()
                        self?.dismiss(animated: true, completion: nil)
                    case .failure:
                        // To modify
                        let alert = UIAlertController(title: "Error", message: "Error while updating your recipe", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                        saveRecipeToRealm { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success:
                                self.recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
                                self.dismiss(animated: true, completion: nil)
        //                        self.doneButton.isHidden = true
        //                        self.activityIndicator.startAnimating()
        //                        CloudManager.shared.saveCustomRecipeOnCloud(customRecipe: self.customRecipe) { [weak self] result in
        //                            guard let self = self else { return }
        //                            self.activityIndicator.stopAnimating()
        //                            self.doneButton.isHidden = false
        //                            switch result {
        //                            case .success(let recordId):
        //                                self.doneButton.isHidden = true
        //                                self.activityIndicator.startAnimating()
        //                                CloudManager.shared.saveIngredientsForCustomRecipeOnCloud(customRecipeRecordId: recordId, ingredients: self.temporaryIngredients) { [weak self] result in
        //                                    guard let self = self else { return }
        //                                    self.activityIndicator.stopAnimating()
        //                                    self.doneButton.isHidden = false
        //                                    switch result {
        //                                    case .success:
        //                                        let alert = UIAlertController(title: "Recipe saved", message: "", preferredStyle: .alert)
        //                                        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        //                                        alert.addAction(action)
        //                                        self.present(alert, animated: true, completion: nil)
        //                                    case .failure(let error):
        //                                        let alert = UIAlertController(title: "Error Cloud", message: error.localizedDescription, preferredStyle: .alert)
        //                                        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        //                                        alert.addAction(action)
        //                                        self.present(alert, animated: true, completion: nil)
        //                                    }
        //                                }
        //                            case.failure(let error):
        //                                let alert = UIAlertController(title: "Error Cloud", message: error.localizedDescription, preferredStyle: .alert)
        //                                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        //                                alert.addAction(action)
        //                                self.present(alert, animated: true, completion: nil)
        //                            }
        //                        }
                            case .failure:
                                // To modify
                                let alert = UIAlertController(title: "Error", message: "Error while saving your recipe", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    
                }
    }
    
    
    @IBAction func didTapStepper(_ sender: UIStepper) {
        servings = Int(sender.value)
    }
    
    @IBAction func didTapAddImage(_ sender: UIButton) {
        switch imageState {
        case .addPic:
            presentImagePicker()
        case .deleteOrModifyPic:
            let alert = UIAlertController(title: "My image", message: "", preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = addImageButton
            alert.popoverPresentationController?.sourceRect = addImageButton.bounds
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let change = UIAlertAction(title: "Change", style: .default) { action in
                self.presentImagePicker()
            }
            let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.recipeImageView.image = UIImage(named: "imagePlaceholderBig.png")
                self.addImageButton.setTitle("Add Image", for: .normal)
                self.imageState = .addPic
                self.downloadUrl = nil
            }
            alert.addAction(cancel)
            alert.addAction(change)
            alert.addAction(delete)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapBottomAdd(_ sender: Any) {
        self.removeStartView()
        
        newThingView?.mainTextField.becomeFirstResponder()
        newThingView?.updateUI(type: .createRecipe, selectedSection: "Name")
//        NotificationCenter.default.post(name: Notification.Name("keyboardWillShow"), object: nil)
        bottomEditButton.isHidden = false
    }
    
    @IBAction func didTapBottomEditButton(_ sender: Any) {
        if self.editingMode {
            editingMode = false
        } else {
            // guard sth
            guard !(temporaryIngredients.isEmpty && temporarySteps.isEmpty) else { return }
            editingMode = true
        }
//        self.editingMode = !editingMode
        print(editingMode)
    }
    
    
//    @IBAction func didTapAddIngredient(_ sender: UIButton) {
//        addIngredient()
//    }
    
    
    
//    @IBAction func didTapAddStep(_ sender: UIButton) {
//        if let step = stepTextField.text {
//            if step.isEmpty {
////                addStepButton.shake()
//                return
//            } else {
//                if let row = selectedRowStep {
//                    temporarySteps.remove(at: row)
//                    temporarySteps.insert(step, at: row)
//                    selectedRowStep = nil
//                } else {
//                    temporarySteps.append(step)
//                }
//            }
//        }
//        stepTextField.text = ""
//
//    }
    

}

// MARK: TextFieldDelegate / TextViewDelegate
extension RecipeCreationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        
        // Pass to AddThingView
        DispatchQueue.main.async {

            switch textField {
            case self.recipeNameTextField:
                self.newThingView?.selectedSection = CreateRecipeSections.name.rawValue

            case self.ingredientTextField:

                self.newThingView?.selectedSection = CreateRecipeSections.ingredient.rawValue

                    
            case self.stepTextField:
                self.newThingView?.selectedSection = CreateRecipeSections.step.rawValue
            default:
                break
            }

            self.newThingView?.mainTextField.becomeFirstResponder()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension RecipeCreationViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == commentsTextView {
            newThingView?.mainTextField.becomeFirstResponder()
            newThingView?.selectedSection = CreateRecipeSections.comment.rawValue
        }

    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
       commentsTextView.resignFirstResponder()
       return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//          super.touchesBegan(touches, with: event)
//          self.view.endEditing(true)
//      }
    
    
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
        addImageButton.setTitle("Edit Image", for: .normal)
        
        picturePicker.dismiss(animated: true, completion: nil)
        
        if let recipeImage = recipeImage {
            doneButton.isHidden = true
            activityIndicator.startAnimating()
            Event.shared.saveRecipePicToFirebase(recipeImage, id: customRecipe.id) { [weak self] result in
                self?.doneButton.isHidden = false
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let url):
                    self?.downloadUrl = url
                case .failure:
                    let alert = UIAlertController(title: "Error while saving image", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    self?.recipeImageView.image = UIImage(named: "imagePlaceholderBig.png")
                }
            }
        }
        
        
    }
}

// MARK: TableView Configure
extension RecipeCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case ingredientsTableView:
            return temporaryIngredients.count
        case stepsTableView:
            return temporarySteps.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ingredientCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.ingredientCell, for: indexPath) as! IngredientCell
        
        switch tableView {
        case ingredientsTableView:
            let ingredient = temporaryIngredients[indexPath.row]
                ingredientCell.configureCell(name: ingredient.name, amount: ingredient.amount ?? 0, unit: ingredient.unit ?? "")
            return ingredientCell
        case stepsTableView:
            let step = temporarySteps[indexPath.row]
//            ingredientCell.configureCell(name: step, amount: 0, unit: "")
            ingredientCell.configureCellWithStep(name: step, step: indexPath.row + 1)
            return ingredientCell
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
                case ingredientsTableView:
                    temporaryIngredients.remove(at: indexPath.row)
                case stepsTableView:
                    temporarySteps.remove(at: indexPath.row)
                default:
                    break
                }
            }
        }
    
    
     func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch tableView {
        case ingredientsTableView:
            let movedObject = temporaryIngredients[sourceIndexPath.row]
            temporaryIngredients.remove(at: sourceIndexPath.row)
            temporaryIngredients.insert(movedObject, at: destinationIndexPath.row)
        case stepsTableView:
            let movedObject = temporarySteps[sourceIndexPath.row]
            temporarySteps.remove(at: sourceIndexPath.row)
            temporarySteps.insert(movedObject, at: destinationIndexPath.row)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case ingredientsTableView:
            selectedRowIngredient = indexPath.row
            let selectedIngredient = temporaryIngredients[indexPath.row]
            ingredientTextField.text = selectedIngredient.name
            //MARK: To be precise, should pop up at the addthingview
            if let amount = selectedIngredient.amount {
//                amountTextField.text = String(amount)
            }
            if let unit = selectedIngredient.unit {
//                unitTextField.text = unit
            }
        case stepsTableView:
            selectedRowStep = indexPath.row
            let selectedStep = temporarySteps[indexPath.row]
            stepTextField.text = selectedStep
            
        default:
            break
        }
    }
    
}

// MARK: ScrollView Delegate

extension RecipeCreationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        print(yOffset)
        
        if yOffset < -topViewMaxHeight {
            heightConstraint.constant = self.topViewMaxHeight
            recipeImageView.layer.cornerRadius = 15
            
        } else if yOffset < -topViewMinHeight {
            heightConstraint.constant = yOffset * -1
            recipeImageView.layer.cornerRadius = yOffset * (topViewMinHeight / topViewMaxHeight) * -5 / 15
            self.view.layoutIfNeeded()
             
        } else {
            heightConstraint.constant = topViewMinHeight
            recipeImageView.layer.cornerRadius = 5
        }
        
        if heightConstraint.constant == topViewMaxHeight {
            addImageButton.alpha = 1
        } else {
            addImageButton.alpha = 0
        }
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        // Scroll View Respone
        scrollView.contentInset = UIEdgeInsets(top: topViewMinHeight, left: 0, bottom: bottomEdgeInset, right: 0) //keyboardFrame.height
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        var rectangle = self.view.frame
        rectangle.size.height -= keyboardFrame.height
        
        if let activeField = activeField {
            if !rectangle.contains(activeField.frame.origin) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
        
        if activeField == nil {
            scrollView.scrollRectToVisible(commentsTextView.frame, animated: true)
        }
    
        // AddThingView Respone
        showAddThingView(true, keyboardHeight: keyboardFrame.height)
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        showAddThingView(false, keyboardHeight: nil)
    
        activeField?.resignFirstResponder()
    }
    
    private func showAddThingView(_ bool: Bool, keyboardHeight: CGFloat?) {
        if bool {
            
            guard let keyboardHeight = keyboardHeight else {return}
            
            UIView.animate(withDuration: 1) {
                self.addThingViewBottomConstraint.constant = keyboardHeight
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.addThingViewBottomConstraint.constant += 20
                }
                
            }
            
            self.view.addGestureRecognizer(self.tapGestureToHideKeyboard)
            self.view.addGestureRecognizer(self.swipeDownGestureToHideKeyBoard)
        } else {
            
            UIView.animate(withDuration: 1) {
                self.addThingViewBottomConstraint.constant = -100
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.addThingViewBottomConstraint.constant -= 20
                }
            }
           
           self.view.removeGestureRecognizer(self.tapGestureToHideKeyboard)
           self.view.removeGestureRecognizer(self.swipeDownGestureToHideKeyBoard)
        }
        
        self.view.layoutIfNeeded()

    }
    
}


extension RecipeCreationViewController: AddThingDelegate {
    
    // Pass thing from AddThingView
    func doneEditThing(selectedSection: String?, mainContent: String?, amount: String?, unit: String?) {
        switch selectedSection {
        case CreateRecipeSections.name.rawValue:
            recipeNameTextField.text = mainContent
        case CreateRecipeSections.ingredient.rawValue:
            addIngredient(name: mainContent, amount: amount, unit: unit)
        case CreateRecipeSections.step.rawValue:
            addCookingStep(step: mainContent)
        case CreateRecipeSections.comment.rawValue:
            addComment(comment: mainContent)
        default:
            break
        }
    }
}

extension RecipeCreationViewController: UIGestureRecognizerDelegate {
    // To prevent touch in "Add Thing" View
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: addThingView) {
            return false
        }
        return true
    }
}
