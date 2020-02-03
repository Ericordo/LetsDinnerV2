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

class RecipeCreationViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var stepTextField: UITextField!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addStepButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var servingsStepper: UIStepper!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    private let realm = try! Realm()
    
    private let rowHeight : CGFloat = 44
    
    private let topViewMinHeight: CGFloat = 90
    private let topViewMaxHeight: CGFloat = 160
    
    private let picturePicker = UIImagePickerController()
    
    private var recipeImage: UIImage?
    private var downloadUrl: String?
       
    private var imageState : ImageState = .addPic
    
    private var activeField: UITextField?
    
    private let customRecipe = CustomRecipe()
    
    private var imageDeletedWhileEditing = false
    
    weak var recipeCreationVCDelegate: RecipeCreationVCDelegate?
    weak var recipeCreationVCUpdateDelegate: RecipeCreationVCUpdateDelegate?
    
    private var temporaryIngredients = [TemporaryIngredient]() {
        didSet {
            ingredientsTableView.reloadData()
            ingredientsTableViewHeightConstraint.constant = CGFloat(temporaryIngredients.count)*rowHeight
            contentViewHeightConstraint.constant = 600 + ingredientsTableViewHeightConstraint.constant + stepsTableViewHeightConstraint.constant
        }
    }
    
    private var temporarySteps = [String]() {
        didSet {
            stepsTableView.reloadData()
            stepsTableViewHeightConstraint.constant = CGFloat(temporarySteps.count)*rowHeight
            contentViewHeightConstraint.constant = 600 + ingredientsTableViewHeightConstraint.constant + stepsTableViewHeightConstraint.constant
        }
    }
    
    private var servings : Int = 2 {
           didSet {
               servingsLabel.text = "For \(servings) people"
           }
       }
    
    private var placeholderLabel = UILabel()
    
    var recipeToEdit: CustomRecipe?
    var editingMode = false
    
    private var selectedRowIngredient: Int?
    private var selectedRowStep: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if editingMode {
            setupEditingUI()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        recipeNameTextField.delegate = self
        ingredientTextField.delegate = self
        amountTextField.delegate = self
        unitTextField.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.delegate = self
        picturePicker.delegate = self
        scrollView.delegate = self
        stepTextField.delegate = self
        commentsTextView.delegate = self
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        
        ingredientsTableView.register(UINib(nibName: CellNibs.ingredientCell, bundle: nil), forCellReuseIdentifier: CellNibs.ingredientCell)
        stepsTableView.register(UINib(nibName: CellNibs.ingredientCell, bundle: nil), forCellReuseIdentifier: CellNibs.ingredientCell)
       
          NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func setupUI() {
        ingredientsTableView.isEditing = true
        stepsTableView.isEditing = true
        ingredientsTableView.allowsSelectionDuringEditing = true
        stepsTableView.allowsSelectionDuringEditing = true
        recipeImageView.layer.cornerRadius = 17
        ingredientsTableView.rowHeight = rowHeight
        stepsTableView.rowHeight = rowHeight
        ingredientsTableViewHeightConstraint.constant = 0
        stepsTableViewHeightConstraint.constant = 0
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        servingsLabel.text = "For \(servings) people"
        servingsStepper.minimumValue = 2
        servingsStepper.maximumValue = 12
        servingsStepper.stepValue = 1
        servingsStepper.value = Double(servings)
        commentsTextView.tintColor = Colors.newGradientRed
        placeholderLabel.text = LabelStrings.cookingTipsPlaceholder
        placeholderLabel.sizeToFit()
        commentsTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (commentsTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = Colors.customGray
        placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        placeholderLabel.isHidden = !commentsTextView.text.isEmpty
    }
    
    private func setupEditingUI() {
        guard let recipe = recipeToEdit else { return }
        headerLabel.text = recipe.title
        if let downloadUrl = recipe.downloadUrl {
            recipeImageView.kf.indicatorType = .activity
            recipeImageView.kf.setImage(with: URL(string: downloadUrl), placeholder: UIImage(named: "imagePlaceholder")) { result in
                switch result {
                case .success:
                    self.addImageButton.setTitle("Modify image", for: .normal)
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
    
    private func presentPicker() {
        picturePicker.popoverPresentationController?.sourceView = addImageButton
        picturePicker.popoverPresentationController?.sourceRect = addImageButton.bounds
        picturePicker.sourceType = .photoLibrary
        picturePicker.allowsEditing = true
        present(picturePicker, animated: true, completion: nil)
    }
    
    @objc private func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
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
    
    private func verifyInformation() -> Bool {
        if let recipeName = recipeNameTextField.text {
            if recipeName.isEmpty {
                recipeNameTextField.shake()
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapDone(_ sender: Any) {
        if verifyInformation() {
            
            if editingMode {
                guard let recipeToEdit = recipeToEdit else { return }
                updateRecipeInRealm(recipe: recipeToEdit) { [weak self] result in
                    switch result {
                    case .success:
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
                    switch result {
                    case .success:
                        self?.recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
                        self?.dismiss(animated: true, completion: nil)
                    case .failure:
                        // To modify
                        let alert = UIAlertController(title: "Error", message: "Error while saving your recipe", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)
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
            presentPicker()
        case .deleteOrModifyPic:
            let alert = UIAlertController(title: "My image", message: "", preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = addImageButton
            alert.popoverPresentationController?.sourceRect = addImageButton.bounds
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let change = UIAlertAction(title: "Change", style: .default) { action in
                self.presentPicker()
            }
            let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.recipeImageView.image = UIImage(named: "imagePlaceholder")
                self.addImageButton.setTitle("Add image", for: .normal)
                self.imageState = .addPic
                self.downloadUrl = nil
            }
            alert.addAction(cancel)
            alert.addAction(change)
            alert.addAction(delete)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func didTapAddIngredient(_ sender: UIButton) {
        addIngredient()
    }
    
    private func addIngredient() {
        var ingredient: TemporaryIngredient
        if let name = ingredientTextField.text, let amount = amountTextField.text, let unit = unitTextField.text {
            if name.isEmpty {
                addButton.shake()
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
        amountTextField.text = ""
        unitTextField.text = ""

    }
    
    @IBAction func didTapAddStep(_ sender: UIButton) {
        if let step = stepTextField.text {
            if step.isEmpty {
                addStepButton.shake()
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
    

}

extension RecipeCreationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
        addImageButton.setTitle("Modify image", for: .normal)
        
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
                    self?.recipeImageView.image = UIImage(named: "imagePlaceholder")
                }
            }
        }
        
        
    }
}

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
        
//        return ingredientCell
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
            if let amount = selectedIngredient.amount {
                amountTextField.text = String(amount)
            }
            if let unit = selectedIngredient.unit {
                unitTextField.text = unit
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

extension RecipeCreationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        print(yOffset)
        if yOffset < -topViewMaxHeight {
            heightConstraint.constant = self.topViewMaxHeight
           
            
        } else if yOffset < -topViewMinHeight {
            heightConstraint.constant = yOffset * -1
            
        } else {
            heightConstraint.constant = topViewMinHeight
        }
        
        if heightConstraint.constant == topViewMaxHeight {
            addImageButton.alpha = 1
        } else {
            addImageButton.alpha = 0
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: keyboardFrame.height, right: 0)
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
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
}

extension RecipeCreationViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
           commentsTextView.resignFirstResponder()
           return true
       }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          super.touchesBegan(touches, with: event)
          self.view.endEditing(true)
      }
    
    
    
}
