//
//  SelectedRecipesViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 6/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SafariServices
import MobileCoreServices

class SelectedRecipesViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var recipesTableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    
    var previouslySelectedRecipes = [Recipe]()
    var previouslySelectedCustomRecipes = [CustomRecipe]()
    var totalNumberOfSelectedRecipes: Int = 0 {
        didSet {
            updateHeaderLabel()
            updateRearrangeTextLabel()
            showEmptyScreenConfiguration()
        }
    }
    
    weak var dismissDelegate: ModalViewHandler?
    
    var rearrangeTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTableView()
        
        updateLocalVariable()
        updateNumberOfTotalRecipe()
        
        recipesTableView.dragInteractionEnabled = true
        recipesTableView.dragDelegate = self
        recipesTableView.dropDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLocalVariable()
        updateNumberOfTotalRecipe()
        recipesTableView.reloadData()
    }
    
    func configureUI() {
        
    }
    
    private func updateRearrangeTextLabel() {
        if totalNumberOfSelectedRecipes > 1 {
            rearrangeTextLabel.isHidden = false
        } else {
            UIView.animate(withDuration: 0.7,
                           delay: 0.0, options: .transitionCrossDissolve,
                           animations: { self.rearrangeTextLabel.alpha = 0.3 },
                           completion: { finished in self.rearrangeTextLabel.isHidden = true})
        }
    }
    
    private func updateNumberOfTotalRecipe() {
        self.totalNumberOfSelectedRecipes = previouslySelectedRecipes.count + previouslySelectedCustomRecipes.count
    }
    
    private func updateLocalVariable() {
        previouslySelectedRecipes = Event.shared.selectedRecipes
        previouslySelectedCustomRecipes = Event.shared.selectedCustomRecipes
    }
    
    private func updateHeaderLabel() {
        if totalNumberOfSelectedRecipes < 2 {
            headerLabel.text = "YOU HAVE SELECTED \(totalNumberOfSelectedRecipes) RECIPE"
        } else {
            headerLabel.text = "YOU HAVE SELECTED \(totalNumberOfSelectedRecipes) RECIPES"
        }
    }
    
    private func showEmptyScreenConfiguration() {
        if totalNumberOfSelectedRecipes == 0 {
            headerLabel.isHidden = true
            recipesTableView.tableFooterView?.isHidden = true
        } else {
            headerLabel.isHidden = false
            recipesTableView.tableFooterView?.isHidden = false
        }
    }
    
    private func openRecipeInSafari(recipe: Recipe) {
        guard let sourceUrl = recipe.sourceUrl else { return }
        if let url = URL(string: sourceUrl) {
            let vc = CustomSafariVC(url: url)
            present(vc, animated: true, completion: nil)
        }
    }
    
    func configureTableView() {
        recipesTableView.register(UINib(nibName: CellNibs.recipeCell, bundle: nil), forCellReuseIdentifier: CellNibs.recipeCell)
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        // FooterView
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: recipesTableView.frame.width, height: 40))
        footerView.backgroundColor = .clear
        
        let textLabel1: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 5, width: self.view.frame.width , height: 15)
            label.text = "To delete a recipes, swipe left."
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 12)
            label.textAlignment = .center
            label.backgroundColor = .clear
            return label
        }()
        
        rearrangeTextLabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 25, width: recipesTableView.frame.width , height: 15)
            label.text = "To rearrange the order, tap and hold to move."
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 12)
            label.textAlignment = .center
            return label
        }()
        
        footerView.addSubview(textLabel1)
        footerView.addSubview(rearrangeTextLabel)
        
        recipesTableView.tableFooterView = footerView
        recipesTableView.separatorStyle = .none
        recipesTableView.rowHeight = 120
        recipesTableView.showsVerticalScrollIndicator = false
        
        textLabel1.translatesAutoresizingMaskIntoConstraints = false
        rearrangeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel1.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        rearrangeTextLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        textLabel1.anchor(top: footerView.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        rearrangeTextLabel.anchor(top: textLabel1.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
    }

    @IBAction func didTapDone(_ sender: Any) {
        self.dismissDelegate?.reloadTableAfterModalDismissed()
        self.dismiss(animated: true, completion: nil)
    }
    

}

// MARK: TableView Configuration

extension SelectedRecipesViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if totalNumberOfSelectedRecipes == 0 {
            tableView.setEmptyViewForRecipeView(title: LabelStrings.noRecipeTitle, message: LabelStrings.noRecipeMessage)
        } else {
            tableView.restore()
        }
        
        return totalNumberOfSelectedRecipes
    }
     
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = recipesTableView.dequeueReusableCell(withIdentifier: CellNibs.recipeCell, for: indexPath) as! RecipeCell
        cell.recipeCellDelegate = self
        cell.chosenButton.isUserInteractionEnabled = false
        
        // MARK: Present Custom Recipes First
//        if !previouslySelectedCustomRecipes.isEmpty || !previouslySelectedRecipes.isEmpty {
//
//            if indexPath.row < previouslySelectedCustomRecipes.count {
//                let recipe = previouslySelectedCustomRecipes[indexPath.row]
//                cell.configureCellWithCustomRecipe(customRecipe: recipe, isSelected: true, searchType: .customRecipes)
//
//            } else {
//                // Present API recipes
//                let recipe = previouslySelectedRecipes[indexPath.row - previouslySelectedCustomRecipes.count]
//                cell.configureCell(recipe: recipe, isSelected: true, searchType: .apiRecipes)
//            }
//
//            cell.recipeCellDelegate = self
//            cell.chosenButton.isUserInteractionEnabled = false
//            return cell
//
//        } else {
//            return UITableViewCell()
//        }
        
        // MARK: Present according to Custom Order
        
        // Find the customr order available in the two arrays
        
        // Match the indexPath with customOrder
        if !previouslySelectedRecipes.isEmpty {
            for recipe in previouslySelectedRecipes {
                if indexPath.row == recipe.customOrder - 1 {
                    // Present the cell
                    cell.configureCell(recipe: recipe, isSelected: true, searchType: .apiRecipes)
                    return cell
                }
            }
        }
        
        if !previouslySelectedCustomRecipes.isEmpty {
            for recipe in previouslySelectedCustomRecipes {
                if indexPath.row == recipe.customOrder - 1 {
                    // Present the cell
                    cell.configureCellWithCustomRecipe(customRecipe: recipe, isSelected: true, searchType: .customRecipes)
                    return cell
                }
            }
        }
                    
        return UITableViewCell()
    }
    
    // MARK: Editing row
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Apirecipe index number = self + customrecipe index
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, complete in
//            self.Items.remove(at: indexPath.row)
            let cell = tableView.cellForRow(at: indexPath) as! RecipeCell
            

            switch cell.searchType {
            case .customRecipes:
                if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == cell.selectedCustomRecipe.id }) {
                    
                    Event.shared.reassignCustomOrderAfterRemoval(recipeType: .customRecipes, index: index)
                    Event.shared.selectedCustomRecipes.remove(at: index)
                    self.updateLocalVariable()
                    self.updateNumberOfTotalRecipe()
                    
                    
//                    self.recipesTableView.reloadData()
                    // Animation needed
                    
//                    self.recipesTableView.deleteRows(at: [indexPath], with: .automatic)
                    UIView.animate(withDuration: 0.4,
                                   delay: 0.0, options: .transitionCrossDissolve,
                                   animations: { cell.alpha = 0.3 },
                                   completion: { finished in self.recipesTableView.reloadData()})
                    }
                    
            case .apiRecipes:
                if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.id == cell.selectedRecipe.id }) {
                    
                    Event.shared.reassignCustomOrderAfterRemoval(recipeType: .apiRecipes, index: index)
                    Event.shared.selectedRecipes.remove(at: index)
                    self.updateLocalVariable()
                    self.updateNumberOfTotalRecipe()
//                    self.recipesTableView.reloadData()
                    
                    UIView.animate(withDuration: 0.4,
                                   delay: 0.0, options: .transitionCrossDissolve,
                                   animations: { cell.alpha = 0.3 },
                                   completion: { finished in self.recipesTableView.reloadData()})
                }
  
            }
            
            complete(true)
        }
        

        deleteAction.image = UIImage(named: "deleteBin")
        deleteAction.backgroundColor = .backgroundColor
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    // MARK: Reorder (Drag and Drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // ipad is not calling this function
        // Tableview Datasource: previouslyselectedRecipe
        // Use Global (Event.shared) to maintain datasource, then update local var
        
        let movedCell = tableView.cellForRow(at: sourceIndexPath) as! RecipeCell
        let destinatedCell = tableView.cellForRow(at: destinationIndexPath) as! RecipeCell
        var movedObject: Any?
        
//        print("sourceIndex \(sourceIndexPath) , destIndex: \(destinationIndexPath)")
        
        var movedObjectSourceCustomOrder: Int?
        var movedObjectDestinatedCustomOrder: Int?

        switch movedCell.searchType {
        case .apiRecipes:
            // Get the movedObject
            for index in 0 ... previouslySelectedRecipes.count - 1 {
                if previouslySelectedRecipes[index].customOrder == movedCell.selectedRecipe.customOrder {
                    movedObject = previouslySelectedRecipes[index]
                    
                    // Get sourceCustomerOrder
                    movedObjectSourceCustomOrder = (movedObject as! Recipe).customOrder
                }
            }
        case .customRecipes:
            for index in 0 ... previouslySelectedCustomRecipes.count - 1 {
                if previouslySelectedCustomRecipes[index].customOrder == movedCell.selectedCustomRecipe.customOrder {
                    movedObject = previouslySelectedCustomRecipes[index]
                    
                    movedObjectSourceCustomOrder = (movedObject as! CustomRecipe).customOrder
                }
            }
        }
        
        // Get desintationCustomerOrder
        switch destinatedCell.searchType {
        case .apiRecipes:
            movedObjectDestinatedCustomOrder = destinatedCell.selectedRecipe.customOrder
        case .customRecipes:
            movedObjectDestinatedCustomOrder = destinatedCell.selectedCustomRecipe.customOrder
        }
        
//        print(previouslySelectedRecipes.map{$0.title})
//        print(previouslySelectedRecipes.map{$0.customOrder})
        
        if let sourceCustomOrder = movedObjectSourceCustomOrder, let destinationCustomOrder = movedObjectDestinatedCustomOrder,
            let movedObject = movedObject {
            Event.shared.reassignCustomOrderAfterReorder(sourceCustomOrder: sourceCustomOrder, destinationCustomOrder: destinationCustomOrder, movedObject: movedObject)
        }
        
        self.updateLocalVariable()
        
        DispatchQueue.main.async {
            self.recipesTableView.reloadData()
        }
        
        print("After Reorder:")
        print(previouslySelectedRecipes.map{$0.title})
        print(previouslySelectedRecipes.map{$0.customOrder})
        print(previouslySelectedCustomRecipes.map{$0.title})
        print(previouslySelectedCustomRecipes.map{$0.customOrder})

        //        UIView.transition(with: recipesTableView, duration: 0.3,
        //                          options: .transitionCrossDissolve,
        //                          animations: {self.previouslySelectedRecipes.insert(movedObject, at: destinationIndexPath.row)},
        //                          completion: nil)
        
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
     
}
 
extension SelectedRecipesViewController: UITableViewDropDelegate, UITableViewDragDelegate {


    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            return [UIDragItem(itemProvider: NSItemProvider())]
        }


    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

       if session.localDragSession != nil { // Drag originated from the same app.
           return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
       }

       return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
   }

   func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    
//        let destinationIndexPath: IndexPath
//        if let indexPath = coordinator.destinationIndexPath {
//            destinationIndexPath = indexPath
//        } else {
//            let section = tableView.numberOfSections - 1
//            let row = tableView.numberOfRows(inSection: section)
//            destinationIndexPath = IndexPath(row: row, section: section)
//        }
//
//        print(destinationIndexPath)

    }

}
    
// MARK: Delegate for recipeVC

extension SelectedRecipesViewController: RecipeCellDelegate {
    
    func recipeCellDidSelectRecipe(recipe: Recipe) {
        print("Disabled")
    }
    
    func recipeCellDidSelectCustomRecipe(customRecipe: CustomRecipe) {
        print("Disabled")
    }
    
    func recipeCellDidSelectView(recipe: Recipe) {
        openRecipeInSafari(recipe: recipe)
    }
    
    func recipeCellDidSelectCustomRecipeView(customRecipe: CustomRecipe) {
        let customRecipeDetailsVC = CustomRecipeDetailsViewController()
        customRecipeDetailsVC.modalPresentationStyle = .fullScreen
        customRecipeDetailsVC.selectedRecipe = customRecipe
//        customRecipeDetailsVC.customRecipeDetailsDelegate = self

        present(customRecipeDetailsVC, animated: true, completion: nil)
    }
    
    
}
