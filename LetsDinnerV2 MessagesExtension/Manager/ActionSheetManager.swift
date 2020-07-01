//
//  ActionSheetManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 1/7/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class ActionSheetManager {
        
    init() {
    }
    
    let cancelAction = UIAlertAction(title: AlertStrings.cancel, style: .cancel, handler: nil)
    
    // MARK: RegistrationVC
    func presentSaveActionSheetInReigstrationVC(controller: RegistrationViewController) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: AlertStrings.doneActionSheetMessage, preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = controller.navigationBar.nextButton
        alert.popoverPresentationController?.sourceRect = controller.navigationBar.nextButton.bounds
        
        let saveAction = UIAlertAction(title: AlertStrings.save, style: .default) { _ in
            controller.view.endEditing(true)
            controller.firstNameTextField.animateEmpty()
            controller.lastNameTextField.animateEmpty()
            controller.errorLabel.isHidden = controller.viewModel.infoIsValid()
            if controller.viewModel.infoIsValid() {
                controller.viewModel.saveUserInformation()
            }
        }
        let discardAction = UIAlertAction(title: AlertStrings.discard, style: .destructive) { _ in
            controller.delegate?.registrationVCDidTapCancelButton()
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        alert.addAction(discardAction)
        return alert
    }
    
    func presentDeleteOrChangeImage (controller: RegistrationViewController) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: AlertStrings.changeImageActionSheetMessage, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = controller.addPicButton
        alert.popoverPresentationController?.sourceRect = controller.addPicButton.bounds
        let change = UIAlertAction(title: AlertStrings.change, style: .default) { action in
            controller.presentPicker()
        }
        let delete = UIAlertAction(title: AlertStrings.delete, style: .destructive) { action in
            controller.viewModel.deleteProfilePicture()
        }
        alert.addAction(cancelAction)
        alert.addAction(change)
        alert.addAction(delete)
        return alert
    }
    
    // MARK: RecipeCreationVC
    func presentEditActionSheetInRecipeCreationVC(controller: RecipeCreationViewController) -> UIAlertController {
        let alert = UIAlertController(title: nil,
                                      message: String.localizedStringWithFormat(AlertStrings.editRecipeActionSheetMessage, controller.recipeToEdit?.title ?? ""), preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = controller.bottomEditButton
        alert.popoverPresentationController?.sourceRect = controller.bottomEditButton.bounds
        
        let editAction = UIAlertAction(title: AlertStrings.editAction, style: .default) { _ in
            controller.editingMode = true
            controller.editExistingRecipe = true
            controller.updateEditingModeUI(enterEditingMode: true) }
        let deleteAction = UIAlertAction(title: AlertStrings.delete, style: .destructive) { _ in
            guard let recipe = controller.recipeToEdit else { return }
            controller.viewModel.deleteRecipe(recipe) }
        alert.addAction(cancelAction)
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        return alert
    }
    
    func presentDoneActionSheetInRecipeCreationVC(controller: RecipeCreationViewController) -> UIAlertController {
    
        let alert = UIAlertController(title: nil, message: AlertStrings.doneActionSheetMessage, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = controller.doneButton
        alert.popoverPresentationController?.sourceRect = controller.doneButton.bounds

        let saveAction = UIAlertAction(title: AlertStrings.save, style: .default) { _ in controller.saveRecipe()
        }
        let discardAction = UIAlertAction(title: AlertStrings.discard, style: .destructive) { _ in
            controller.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        alert.addAction(discardAction)
        return alert
    }
    
}
