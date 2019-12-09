//
//  CustomRecipeDetailsViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import RealmSwift

protocol CustomRecipeDetailsVCDelegate : class {
    func didDeleteCustomRecipe()
}


class CustomRecipeDetailsViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var chosenButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var selectedRecipe: CustomRecipe?
    
    let realm = try! Realm()
    
    weak var customRecipeDetailsDelegate: CustomRecipeDetailsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
    }

    private func setupUI() {
        chooseButton.layer.cornerRadius = 10
        chooseButton.backgroundColor = .white
        guard let recipe = selectedRecipe else { return }
              nameLabel.text = recipe.title
        let isSelected = Event.shared.selectedRecipes.contains(where: { $0.title == recipe.title })
              chooseButton.isHidden = isSelected
              chosenButton.isHidden = !isSelected
    }
    
    private func deleteRecipe() {
        if let recipe = self.selectedRecipe {
            do {
                try self.realm.write {
                    self.realm.delete(recipe)
                }
            } catch {
                print(error)
            }
        }
        customRecipeDetailsDelegate?.didDeleteCustomRecipe()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapChoose(_ sender: UIButton) {
    }
    
    @IBAction func didTapChosen(_ sender: Any) {
    }
    
    @IBAction func didTapEdit(_ sender: UIButton) {
        presentEditMenu()
    }
    
    private func presentEditMenu() {
        let alert = UIAlertController(title: selectedRecipe?.title ?? "", message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = editButton
        alert.popoverPresentationController?.sourceRect = editButton.bounds
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let edit = UIAlertAction(title: "Edit", style: .default) { action in
            
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.deleteRecipe()
        }
        alert.addAction(cancel)
        alert.addAction(edit)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
        
    }
    
   

}
