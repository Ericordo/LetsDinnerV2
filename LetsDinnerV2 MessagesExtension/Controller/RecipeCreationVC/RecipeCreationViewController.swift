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

class RecipeCreationViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    
    private let realm = try! Realm()
    
    private let picturePicker = UIImagePickerController()
       
    private var imageState : ImageState = .addPic
    
    private var readyToSave = false
    
    weak var recipeCreationVCDelegate: RecipeCreationVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        recipeNameTextField.delegate = self
        servingsTextField.delegate = self
        picturePicker.delegate = self
        
          NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
        
    }
    
    private func setupUI() {
        recipeImageView.layer.cornerRadius = 17
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
    
    private func saveRecipeToRealm(completion: @escaping (_ recipes: [Recipe]) -> Void) {
        
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
        do {
            try self.realm.write {
                let customRecipe = CustomRecipe()
                if let recipeImage = recipeImageView.image {
                    customRecipe.imageData = recipeImage.pngData()
                }
                if let recipeTitle = recipeNameTextField.text {
                    customRecipe.title = recipeTitle
                }
                realm.add(customRecipe)
            }
        } catch {
            print(error)
            let alert = UIAlertController(title: "\(error)", message: "\(error.localizedDescription)", preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        }
        recipeCreationVCDelegate?.recipeCreationVCDidTapDone()
        self.dismiss(animated: true, completion: nil)
        
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
                self.recipeImageView.image = UIImage(named: "imageplaceholder")
            }
            alert.addAction(cancel)
            alert.addAction(change)
            alert.addAction(delete)
            self.present(alert, animated: true, completion: nil)
        }
    }
    

}

extension RecipeCreationViewController: UITextFieldDelegate {
    
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
