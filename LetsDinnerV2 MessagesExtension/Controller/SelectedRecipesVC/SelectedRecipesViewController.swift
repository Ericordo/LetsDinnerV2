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
    var previouslySelectedCustomRecipes = [LDRecipe]()
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
        updateTotalNumberOfRecipes()
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLocalVariable()
        updateTotalNumberOfRecipes()
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
                           animations: { self.rearrangeTextLabel.alpha = 0.1 },
                           completion: { (_) in
                            self.rearrangeTextLabel.isHidden = true})
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            rearrangeTextLabel.isHidden = true
        }
    }
    
    private func updateTotalNumberOfRecipes() {
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
        
        recipesTableView.dragInteractionEnabled = true
        recipesTableView.dragDelegate = self
        recipesTableView.dropDelegate = self
        
        // Configure FooterView
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: recipesTableView.frame.width, height: 40))
        footerView.backgroundColor = .clear
        
        let deleteRecipeLabel: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 5, width: self.view.frame.width , height: 15)
            label.text = LabelStrings.deleteRecipeLabel
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 12)
            label.textAlignment = .center
            label.backgroundColor = .clear
            return label
        }()
        
        rearrangeTextLabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: recipesTableView.frame.width , height: 15)
            label.text = LabelStrings.rearrangeRecipeLabel
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 12)
            label.textAlignment = .center
            return label
        }()
        
        footerView.addSubview(deleteRecipeLabel)
        footerView.addSubview(rearrangeTextLabel)
        
        recipesTableView.tableFooterView = footerView
        recipesTableView.separatorStyle = .none
        recipesTableView.rowHeight = 120
        recipesTableView.showsVerticalScrollIndicator = false
        
        deleteRecipeLabel.translatesAutoresizingMaskIntoConstraints = false
        rearrangeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        deleteRecipeLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        rearrangeTextLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        deleteRecipeLabel.anchor(top: footerView.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        rearrangeTextLabel.anchor(top: deleteRecipeLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
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
//        if !previouslySelectedRecipes.isEmpty {
//            for recipe in previouslySelectedRecipes {
//                if indexPath.row == recipe.customOrder - 1 {
//                    // Present the cell
//                    cell.configureCell(recipe: recipe, isSelected: true, searchType: .apiRecipes)
//                    return cell
//                }
//            }
//        }
//
//        if !previouslySelectedCustomRecipes.isEmpty {
//            for recipe in previouslySelectedCustomRecipes {
//                if indexPath.row == recipe.customOrder - 1 {
//                    // Present the cell
//                    cell.configureCellWithCustomRecipe(customRecipe: recipe, isSelected: true, searchType: .customRecipes)
//                    return cell
//                }
//            }
//        }
        
        // Present using CustomOrderHelper
        
        /** Loop through the customOrderHelper
        // check the order no. with the indexPath
        // Find the RecipeID
        // Check its custom or not <-
        configure Cell
        */
 
        for customOrder in CustomOrderHelper.shared.customOrder {
            // If match
            if customOrder.1 == indexPath.row + 1 {
                let recipeType = CustomOrderHelper.shared.checkIfRecipeIsCustom(recipeId: customOrder.0)
                
                switch recipeType {
                case .apiRecipes:
                    if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.id == Int(customOrder.0)} ) {
                        
                        let recipe = Event.shared.selectedRecipes[index]
                        
                        cell.configureCell(recipe)
                        
                        return cell
                    }

                case .customRecipes:
                    if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == customOrder.0} ) {
                        
                        let recipe = Event.shared.selectedCustomRecipes[index]
                        
                        cell.configureCellWithCustomRecipe(recipe)
                        
                        return cell
                    }
                default:
                    break
                }
            }
        }
         
        return UITableViewCell()
    }
    
    // MARK: Delete and Edit row
    
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
                    
//                    Event.shared.reassignCustomOrderAfterRemoval(recipeType: .customRecipes, index: index)
                    CustomOrderHelper.shared.removeRecipeCustomOrder(recipeId: Event.shared.selectedCustomRecipes[index].id)
                    
                    Event.shared.selectedCustomRecipes.remove(at: index)

                    }
                    
            case .apiRecipes:
                if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.id == cell.selectedRecipe.id }) {
                    
//                    Event.shared.reassignCustomOrderAfterRemoval(recipeType: .apiRecipes, index: index)
                    CustomOrderHelper.shared.removeRecipeCustomOrder(recipeId: String(Event.shared.selectedRecipes[index].id!))
                    Event.shared.selectedRecipes.remove(at: index)
 
                }
  
            }
            
            self.updateLocalVariable()
            self.updateTotalNumberOfRecipes()
            
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .transitionCrossDissolve,
                           animations: {
                            cell.alpha = 0.3
                            cell.heightConstraint.constant = 0
                            cell.backgroundCellView.layoutIfNeeded() },
                           completion: { (_) in
                            self.recipesTableView.reloadData()
                            cell.heightConstraint.constant = 110
                            cell.backgroundCellView.layoutIfNeeded()
                            
            })
            
            complete(true)
        }
        
        
        deleteAction.image = UIImage(named: "deleteBin")
        deleteAction.backgroundColor = UIColor.backgroundColor

//        let image = UIImage(named: "recipeDeleteButton")
//        deleteAction.backgroundColor = UIColor(patternImage: image!)
        
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
        
        let movedObjectId: String!
        
        // get the recipeId from sourceIndex
        let sourceOrder = sourceIndexPath.row + 1
        
        
        
        
//        print("sourceIndex \(sourceIndexPath) , destIndex: \(destinationIndexPath)")
        
        /*
        var movedObjectSourceCustomOrder: Int?
        var movedObjectDestinatedCustomOrder: Int?

        switch movedCell.searchType {
        case .apiRecipes:
            // Get the movedObject
            if let index = previouslySelectedRecipes.firstIndex( where: { $0.customOrder == movedCell.selectedRecipe.customOrder}) {
                movedObject = previouslySelectedRecipes[index]
                
                // Get sourceCustomerOrder
                movedObjectSourceCustomOrder = (movedObject as! Recipe).customOrder
            }

        case .customRecipes:
            
            if let index = previouslySelectedCustomRecipes.firstIndex(where: { $0.customOrder == movedCell.selectedCustomRecipe.customOrder}) {
                
                movedObject = previouslySelectedCustomRecipes[index]
                movedObjectSourceCustomOrder = (movedObject as! CustomRecipe).customOrder
            }
        }
        
        // Get desintationCustomOrder
        switch destinatedCell.searchType {
        case .apiRecipes:
            movedObjectDestinatedCustomOrder = destinatedCell.selectedRecipe.customOrder
        case .customRecipes:
            movedObjectDestinatedCustomOrder = destinatedCell.selectedCustomRecipe.customOrder
        }
        
        */
        
//        print(previouslySelectedRecipes.map{$0.title})
//        print(previouslySelectedRecipes.map{$0.customOrder})
        
         CustomOrderHelper.shared.reorderRecipeCustomOrder(sourceOrder: sourceIndexPath.row + 1, destinationOrder: destinationIndexPath.row + 1)
        
//        if let sourceCustomOrder = movedObjectSourceCustomOrder, let destinationCustomOrder = movedObjectDestinatedCustomOrder,
//            let movedObject = movedObject {
//            Event.shared.reassignCustomOrderAfterReorder(sourceCustomOrder: sourceCustomOrder, destinationCustomOrder: destinationCustomOrder, movedObject: movedObject)
            
           
            
//            if movedObject is Recipe {
//                let movedObject = movedObject as! Recipe
//
//                CustomOrderHelper.shared.reorderRecipeCustomOrder(sourceOrder: sourceIndexPath.row + 1, destinationOrder: destinationIndexPath.row + 1)
//
//            } else if movedObject is CustomRecipe {
//                let movedObject = movedObject as! CustomRecipe
//
//                CustomOrderHelper.shared.reorderRecipeCustomOrder(recipeId: movedObject.id, destinationOrder: destinationIndexPath.row + 1)
//            }
//        }
        
//        self.updateLocalVariable()
//
        DispatchQueue.main.async {
            self.recipesTableView.reloadData()
        }
        
//        print("After Reorder:")
//        print(previouslySelectedRecipes.map{$0.title})
//        print(previouslySelectedRecipes.map{$0.customOrder})
//        print(previouslySelectedCustomRecipes.map{$0.title})
//        print(previouslySelectedCustomRecipes.map{$0.customOrder})

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
    
    func recipeCellDidSelectRecipe(_ recipe: Recipe) {}
    
    func recipeCellDidSelectCustomRecipe(_ customRecipe: LDRecipe) {}
    
    func recipeCellDidSelectView(_ recipe: Recipe) {
        openRecipeInSafari(recipe: recipe)
    }
    
    func recipeCellDidSelectCustomRecipeView(_ customRecipe: LDRecipe) {
        let viewCustomRecipeVC = RecipeCreationViewController(viewModel: RecipeCreationViewModel(with: customRecipe, creationMode: false),
                                                              delegate: nil)
        viewCustomRecipeVC.modalPresentationStyle = .overFullScreen
        self.present(viewCustomRecipeVC, animated: true, completion: nil)
    }
}
