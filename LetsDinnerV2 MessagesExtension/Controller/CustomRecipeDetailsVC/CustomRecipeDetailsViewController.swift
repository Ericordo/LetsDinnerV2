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
    func customRecipeDetailsVCShouldDismiss()
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
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    var selectedRecipe: CustomRecipe?
    
    let realm = try! Realm()
    
    private let rowHeight : CGFloat = 44
    private let topViewMinHeight: CGFloat = 55
    private let topViewMaxHeight: CGFloat = 200
    
    weak var customRecipeDetailsDelegate: CustomRecipeDetailsVCDelegate?
    
    var existingEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        ingredientsTableView.register(UINib(nibName: CellNibs.ingredientCell, bundle: nil), forCellReuseIdentifier: CellNibs.ingredientCell)
        stepsTableView.register(UINib(nibName: CellNibs.ingredientCell, bundle: nil), forCellReuseIdentifier: CellNibs.ingredientCell)
        scrollView.delegate = self
  
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
        
    }

    private func setupUI() {
        chooseButton.layer.cornerRadius = 10
        guard let recipe = selectedRecipe else { return }
        nameLabel.text = recipe.title
        ingredientsLabel.text = "INGREDIENTS FOR \(recipe.servings) PEOPLE"
//        if let imageData = recipe.imageData {
//            recipeImageView.image = UIImage(data: imageData)
//        }
        if recipe.ingredients.isEmpty {
            ingredientsHeightConstraint.constant = 0
        } else {
            ingredientsHeightConstraint.constant = CGFloat(recipe.ingredients.count) * rowHeight
        }
        
        if recipe.cookingSteps.isEmpty {
            stepsHeightConstraint.constant = 0
        } else {
            stepsHeightConstraint.constant = CGFloat(recipe.cookingSteps.count) * rowHeight
        }
        
        
        stepsTableView.allowsSelection = false
        stepsTableView.rowHeight = UITableView.automaticDimension
        stepsTableView.estimatedRowHeight = rowHeight
        
        ingredientsHeightConstraint.constant = CGFloat(recipe.ingredients.count) * rowHeight
        let isSelected = Event.shared.selectedCustomRecipes.contains(where: { $0.title == recipe.title })
        
        if UIDevice.current.hasHomeButton {
            bottomViewHeightConstraint.constant = 60
            self.bottomView.layoutIfNeeded()
        }
        
        chooseButton.isHidden = isSelected
        chosenButton.isHidden = !isSelected
        recipeImageView.layer.cornerRadius = 15
        ingredientsTableView.rowHeight = rowHeight
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: topViewMaxHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        if let downloadUrl = recipe.downloadUrl {
             recipeImageView.kf.indicatorType = .activity
             recipeImageView.kf.setImage(with: URL(string: downloadUrl), placeholder: UIImage(named: "imagePlaceholderBig.png")) { result in
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
        commentsLabel.sizeToFit()
        if let comments = recipe.comments {
            commentsLabel.text = comments
        }
        
        chosenButton.isHidden = true
        chooseButton.isHidden = true
        
        if existingEvent {
            editButton.isHidden = true
        }
        
        
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        UIView.animate(withDuration: 0, animations: {
        self.stepsTableView.layoutIfNeeded()
        }) { (complete) in
            var heightOfTableView: CGFloat = 0.0
            let cells = self.stepsTableView.visibleCells
            for cell in cells {
                heightOfTableView += cell.frame.height
            }
            self.stepsHeightConstraint.constant = heightOfTableView
            self.contentViewHeightConstraint.constant = 650 + heightOfTableView + self.ingredientsHeightConstraint.constant
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
    
    private func editRecipe() {
        guard let recipe = self.selectedRecipe else { return }
        
        let editingVC = RecipeCreationViewController()
        editingVC.modalPresentationStyle = .fullScreen
        editingVC.recipeCreationVCUpdateDelegate = self
        editingVC.recipeToEdit = recipe
        editingVC.editExistingRecipe = true
        self.present(editingVC, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapDone(_ sender: UIButton) {
        customRecipeDetailsDelegate?.customRecipeDetailsVCShouldDismiss()
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
        let alert = UIAlertController(title: "", message: selectedRecipe?.title ?? "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = editButton
        alert.popoverPresentationController?.sourceRect = editButton.bounds
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let edit = UIAlertAction(title: "Edit", style: .default) { action in
            self.editRecipe()
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
        switch tableView {
        case ingredientsTableView:
            return (selectedRecipe?.ingredients.count)!
        case stepsTableView:
            return (selectedRecipe?.cookingSteps.count)!
        default:
            return 0
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellNibs.ingredientCell, for: indexPath) as! IngredientCell
        switch tableView {
        case ingredientsTableView:
            if let ingredient = selectedRecipe?.ingredients[indexPath.row] {
            cell.configureCell(name: ingredient.name, amount: ingredient.amount.value ?? 0, unit: ingredient.unit ?? "")
            }
        case stepsTableView:
            if let cookingStep = selectedRecipe?.cookingSteps[indexPath.row] {
                //                cell.configureCell(name: cookingStep, amount: 0, unit: "")
                cell.configureCellWithStep(name: cookingStep, step: indexPath.row + 1)
            }
        default:
            return UITableViewCell()
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
            recipeImageView.layer.cornerRadius = 15

            
        } else if yOffset < -topViewMinHeight {
            heightConstraint.constant = yOffset * -1
            recipeImageView.layer.cornerRadius = yOffset * (topViewMinHeight / topViewMaxHeight) * -5 / 15
            
        } else {
            heightConstraint.constant = topViewMinHeight
            recipeImageView.layer.cornerRadius = 5

        }
    }
}

extension CustomRecipeDetailsViewController: RecipeCreationVCUpdateDelegate {
    
    func recipeCreationVCDidUpdateRecipe() {
        setupUI()
        stepsTableView.reloadData()
        ingredientsTableView.reloadData()
        if selectedRecipe?.downloadUrl == nil {
            recipeImageView.image = UIImage(named: "imagePlaceholderBig.png")
        }
        
        // Edge Case: Add the newly added ingredients to tasks (need to make sure the recipe name are unique)
        if let selectedRecipe = selectedRecipe {
//            let newIngredientNameList = ingredients.map{$0.name}
            
            Event.shared.selectedCustomRecipes.forEach({ customRecipe in
                // find the selected one
                if customRecipe.id == selectedRecipe.id {
                    // compare the ingredients name between tempIngr and orginal
                    let customRecipeNameList: [String] = customRecipe.ingredients.map({$0.name})
                    
                    // compare the list
//                    print(newIngredientNameList)
//                    print(customRecipeNameList)
                    
                    // Remove the old task under the parent name
                    let tasks = Event.shared.tasks.filter {$0.parentRecipe != selectedRecipe.title}
                    Event.shared.tasks = tasks
                    
                    // Add back the task
                    let recipeName = customRecipe.title
                    let servings = Double(customRecipe.servings)
                    let customIngredients = customRecipe.ingredients
                    
                    customIngredients.forEach { customIngredient in
                        let task = Task(taskName: customIngredient.name,
                                        assignedPersonUid: "nil",
                                        taskState: TaskState.unassigned.rawValue,
                                        taskUid: "nil",
                                        assignedPersonName: "nil",
                                        isCustom: false, parentRecipe: recipeName)
                        task.metricUnit = customIngredient.unit
                        if let amount = customIngredient.amount.value {
                            if Int(amount) != 0 {
                                task.metricAmount = (amount * 2) / servings
                            }
                        }
                        task.servings = 2
                        Event.shared.tasks.append(task)
                    }
                    
                    
  
                    
                    
                    
                }
            })
        }
        
    }
    
    
}
