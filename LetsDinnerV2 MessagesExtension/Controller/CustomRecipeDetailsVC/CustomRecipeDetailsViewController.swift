//
//  CustomRecipeDetailsViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

protocol CustomRecipeDetailsVCDelegate : class {
    func didDeleteCustomRecipe()
    func customrecipeDetailsVCShouldDismiss()
}


class CustomRecipeDetailsViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var chosenButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var selectedRecipe: CustomRecipe?
    
    let realm = try! Realm()
    
    private let rowHeight : CGFloat = 44
    
    private let topViewMinHeight: CGFloat = 80
    private let topViewMaxHeight: CGFloat = 140
    
    
    weak var customRecipeDetailsDelegate: CustomRecipeDetailsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.register(UINib(nibName: CellNibs.ingredientCell, bundle: nil), forCellReuseIdentifier: CellNibs.ingredientCell)
        scrollView.delegate = self
        
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
        
    }

    private func setupUI() {
        chooseButton.layer.cornerRadius = 10
        chooseButton.backgroundColor = .white
        guard let recipe = selectedRecipe else { return }
        nameLabel.text = recipe.title
        ingredientsLabel.text = "INGREDIENTS FOR \(recipe.servings) PEOPLE"
//        if let imageData = recipe.imageData {
//            recipeImageView.image = UIImage(data: imageData)
//        }
        let isSelected = Event.shared.selectedCustomRecipes.contains(where: { $0.title == recipe.title })
        chooseButton.isHidden = isSelected
        chosenButton.isHidden = !isSelected
        recipeImageView.layer.cornerRadius = 17
        ingredientsTableView.rowHeight = rowHeight
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        if let downloadUrl = recipe.downloadUrl {
             recipeImageView.kf.indicatorType = .activity
             recipeImageView.kf.setImage(with: URL(string: downloadUrl), placeholder: UIImage(named: "imagePlaceholder")) { result in
                 switch result {
                 case .success:
                    break
                 case .failure:
                     let alert = UIAlertController(title: "Error while retrieving image", message: "", preferredStyle: .alert)
                     alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                     self.present(alert, animated: true, completion: nil)
                 }
             }
         }
    }
    
    private func deleteRecipe() {
        guard let recipe = self.selectedRecipe else { return }
        if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.title == recipe.title }) {
        Event.shared.selectedCustomRecipes.remove(at: index)
        }
            do {
                try self.realm.write {
                    self.realm.delete(recipe)
                }
            } catch {
                print(error)
            }
        customRecipeDetailsDelegate?.didDeleteCustomRecipe()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        customRecipeDetailsDelegate?.customrecipeDetailsVCShouldDismiss()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapChoose(_ sender: UIButton) {
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
        guard let recipe = selectedRecipe else { return }
        if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.title == recipe.title }) {
                  Event.shared.selectedCustomRecipes.remove(at: index)
              } else {
                  Event.shared.selectedCustomRecipes.append(recipe)
              }
    }
    
    @IBAction func didTapChosen(_ sender: UIButton) {
        chooseButton.isHidden = chosenButton.isHidden
               chosenButton.isHidden = !chooseButton.isHidden
               guard let recipe = selectedRecipe else { return }
               if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.title == recipe.title }) {
                         Event.shared.selectedCustomRecipes.remove(at: index)
                     } else {
                         Event.shared.selectedCustomRecipes.append(recipe)
                     }
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

extension CustomRecipeDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectedRecipe?.ingredients.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellNibs.ingredientCell, for: indexPath) as! IngredientCell
        if let ingredient = selectedRecipe?.ingredients[indexPath.row] {
            cell.configureCell(name: ingredient.name, amount: ingredient.amount.value ?? 0, unit: ingredient.unit ?? "")
        }
        return cell
    }
    
    
}

extension CustomRecipeDetailsViewController: UIScrollViewDelegate {
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
    }
}
