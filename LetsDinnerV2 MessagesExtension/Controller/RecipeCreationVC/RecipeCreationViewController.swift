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
    let amount: Double
    let unit: String 
}

class RecipeCreationViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientsTableViewHeightConstraint: NSLayoutConstraint!
    
    private let realm = try! Realm()
    
    private let rowHeight : CGFloat = 44
    
    private let topViewMinHeight: CGFloat = 90
    private let topViewMaxHeight: CGFloat = 160
    
    private let picturePicker = UIImagePickerController()
       
    private var imageState : ImageState = .addPic
    
    private var readyToSave = false
    
    weak var recipeCreationVCDelegate: RecipeCreationVCDelegate?
    
    var temporaryIngredients = [TemporaryIngredient]() {
        didSet {
            ingredientsTableView.isHidden = false
            ingredientsTableView.reloadData()
            ingredientsTableViewHeightConstraint.constant = CGFloat(temporaryIngredients.count)*rowHeight
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        recipeNameTextField.delegate = self
        servingsTextField.delegate = self
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
                let customRecipe = CustomRecipe()
                let customIngredients = List<CustomIngredient>()
                if let recipeImage = recipeImageView.image {
                    customRecipe.imageData = recipeImage.pngData()
                }
                if let recipeTitle = recipeNameTextField.text {
                    customRecipe.title = recipeTitle
                }
                if let servings = Int(servingsTextField.text!) {
                    customRecipe.servings = servings
                }
                temporaryIngredients.forEach { temporaryIngredient in
                    let customIngredient = CustomIngredient()
                    customIngredient.name = temporaryIngredient.name
                    customIngredient.amount.value = temporaryIngredient.amount
                    customIngredient.unit = temporaryIngredient.unit
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
        if let ingredientName = ingredientTextField.text, let ingredientAmount = amountTextField.text {
            if ingredientName.isEmpty || ingredientAmount.isEmpty {
                addButton.shake()
            } else {
                if let amount = Double(ingredientAmount), let unit = unitTextField.text {
                    let newTemporaryIngredient = TemporaryIngredient(name: ingredientName, amount: amount, unit: unit)
                    temporaryIngredients.append(newTemporaryIngredient)
                } else {
                    addButton.shake()
                }
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
        
        guard let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        recipeImageView.image = imageOriginal
        
        imageState = .deleteOrModifyPic
        addImageButton.setTitle("Modify image", for: .normal)
       
        picturePicker.dismiss(animated: true, completion: nil)
    }
}

extension RecipeCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return temporaryIngredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ingredientCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.ingredientCell, for: indexPath) as! IngredientCell
        let ingredient = temporaryIngredients[indexPath.row]
        ingredientCell.configureCell(name: ingredient.name, amount: ingredient.amount, unit: ingredient.unit)
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
