//
//  SelectedRecipesViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 6/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SafariServices

class SelectedRecipesViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var recipesTableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    
    var previouslySelectedRecipes = [Recipe]()
    var previouslySelectedCustomRecipes = [CustomRecipe]()
    var totalNumberOfSelectedRecipes: Int = 0 {
        didSet {
            updateHeaderLabel()
            showEmptyScreen()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTableView()
        
        previouslySelectedRecipes = Event.shared.selectedRecipes
        previouslySelectedCustomRecipes = Event.shared.selectedCustomRecipes
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        totalNumberOfSelectedRecipes = calculateNumberOfTotalRecipe()
        recipesTableView.reloadData()
    }
    
    func configureUI() {

    }
    
    private func calculateNumberOfTotalRecipe() -> Int {
        return previouslySelectedRecipes.count + previouslySelectedCustomRecipes.count
    }
    
    private func updateHeaderLabel() {
        if totalNumberOfSelectedRecipes < 2 {
            headerLabel.text = "YOU HAVE SELECTED \(totalNumberOfSelectedRecipes) RECIPE"
        } else {
            headerLabel.text = "YOU HAVE SELECTED \(totalNumberOfSelectedRecipes) RECIPES"
        }
    }
    
    private func showEmptyScreen() {
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
            let vc = SFSafariViewController(url: url)

            vc.registerForNotification()
            vc.preferredControlTintColor = UIColor.activeButton

            vc.modalPresentationStyle = .overFullScreen
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
            label.frame = CGRect(x: 0, y: 5, width: recipesTableView.frame.width , height: 15)
            label.text = "To delete a recipes, swipe left."
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 12)
            label.textAlignment = .center
            return label
        }()
        
        let textLabel2: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 25, width: recipesTableView.frame.width , height: 15)
            label.text = "To rearrange the order, tap and hold to move."
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 12)
            label.textAlignment = .center
            return label
        }()
        
        footerView.addSubview(textLabel1)
        footerView.addSubview(textLabel2)
        
        recipesTableView.tableFooterView = footerView
        recipesTableView.separatorStyle = .none
        recipesTableView.rowHeight = 120
        recipesTableView.showsVerticalScrollIndicator = false
    }

    @IBAction func didTapDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension SelectedRecipesViewController: UITableViewDelegate, UITableViewDataSource  {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return totalNumberOfSelectedRecipes
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = recipesTableView.dequeueReusableCell(withIdentifier: CellNibs.recipeCell, for: indexPath) as! RecipeCell
        
        // Present Custom Recipes First
        if !previouslySelectedCustomRecipes.isEmpty || !previouslySelectedRecipes.isEmpty {
            
            
            if indexPath.section < previouslySelectedCustomRecipes.count {
                let recipe = previouslySelectedCustomRecipes[indexPath.section]
                cell.configureCellWithCustomRecipe(customRecipe: recipe, isSelected: true, searchType: .customRecipes)

            } else {
                // Present API recipes
                let recipe = previouslySelectedRecipes[indexPath.section - previouslySelectedCustomRecipes.count]
                cell.configureCell(recipe: recipe, isSelected: true, searchType: .apiRecipes)
            }
            
            cell.recipeCellDelegate = self
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    
}
// -> Delegate for recipeVC

extension SelectedRecipesViewController: RecipeCellDelegate {
    func recipeCellDidSelectRecipe(recipe: Recipe) {
        if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.id == recipe.id! }) {
            Event.shared.selectedRecipes.remove(at: index)
        } else {
            Event.shared.selectedRecipes.append(recipe)
        }
        
        // Also for the RecipeVC
    }
    
    func recipeCellDidSelectCustomRecipe(customRecipe: CustomRecipe) {
        if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == customRecipe.id }) {
            Event.shared.selectedCustomRecipes.remove(at: index)
        } else {
            Event.shared.selectedCustomRecipes.append(customRecipe)
        }
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
