//
//  RecipeCreationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import RealmSwift

protocol RecipeCreationVCDelegate: class {
    func recipeCreationVCDidTapDone()
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
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var servingsStepper: UIStepper!
    
    private let realm = try! Realm()
    
    private let rowHeight : CGFloat = 44
    
    private let topViewMinHeight: CGFloat = 90
    private let topViewMaxHeight: CGFloat = 160
    
    private let picturePicker = UIImagePickerController()
    
    private var recipeImage: UIImage?
    private var downloadUrl: String?
       
    private var imageState : ImageState = .addPic
    
    private var readyToSave = false
    
    let customRecipe = CustomRecipe()
    
    weak var recipeCreationVCDelegate: RecipeCreationVCDelegate?
    
    var temporaryIngredients = [TemporaryIngredient]() {
        didSet {
            ingredientsTableView.isHidden = false
            ingredientsTableView.reloadData()
            ingredientsTableViewHeightConstraint.constant = CGFloat(temporaryIngredients.count)*rowHeight
        }
    }
    
    private var servings : Int = 2 {
           didSet {
               servingsLabel.text = "For \(servings) people"
           }
       }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        recipeNameTextField.delegate = self
        ingredientTextField.delegate = self
        amountTextField.delegate = self
        unitTextField.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.delegate = self
        picturePicker.delegate = self
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        ingredientsTableView.register(UINib(nibName: CellNibs.ingredientCell, bundle: nil), forCellReuseIdentifier: CellNibs.ingredientCell)
        ingredientsTableView.isHidden = true
        
          NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
        
    }
    
    private func setupUI() {
        recipeImageView.layer.cornerRadius = 17
        ingredientsTableView.rowHeight = rowHeight
        
        servingsLabel.text = "For \(servings) people"
        servingsStepper.minimumValue = 2
        servingsStepper.maximumValue = 12
        servingsStepper.stepValue = 1
        servingsStepper.value = Double(servings)
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
            saveRecipeToRealm { [weak self] result in
                switch result {
                case .success:
                    self?.recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    // To modify
                    let alert = UIAlertController(title: "\(error)", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "ok", style: .default, handler: nil)
                    alert.addAction(action)
                    self?.present(alert, animated: true, completion: nil)
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
        if let name = ingredientTextField.text, let amount = amountTextField.text, let unit = unitTextField.text {
            if name.isEmpty {
                addButton.shake()
            } else if !amount.isEmpty && !unit.isEmpty {
                let ingredient = TemporaryIngredient(name: name, amount: Double(amount), unit: unit)
                temporaryIngredients.append(ingredient)
            } else if !amount.isEmpty && unit.isEmpty {
                let ingredient = TemporaryIngredient(name: name, amount: Double(amount), unit: nil)
                temporaryIngredients.append(ingredient)
            } else if amount.isEmpty {
                let ingredient = TemporaryIngredient(name: name, amount: nil, unit: nil)
                temporaryIngredients.append(ingredient)
            }
        }
    }
    

}

extension RecipeCreationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    
}

extension RecipeCreationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let imageEdited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        recipeImageView.image = imageEdited
        recipeImage = imageEdited
        
        guard let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        recipeImageView.image = imageOriginal
        recipeImage = imageOriginal
        
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
        return temporaryIngredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ingredientCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.ingredientCell, for: indexPath) as! IngredientCell
        let ingredient = temporaryIngredients[indexPath.row]
        ingredientCell.configureCell(name: ingredient.name, amount: ingredient.amount ?? 0, unit: ingredient.unit ?? "")
        return ingredientCell
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
    

    
 
    
}
