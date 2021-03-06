//
//  RecipesViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol RecipesViewControllerDelegate: class {
        func recipeVCDidTapNext(controller: RecipesViewController)
        func recipeVCDidTapPrevious(controller: RecipesViewController)
}

class RecipesViewController: UIViewController {
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var recipesTableView: UITableView!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: RecipesViewControllerDelegate?
    
    var searchResults = [Recipe]() {
        didSet {
            resultsLabel.isHidden = !searchResults.isEmpty
            recipesTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipesTableView.register(UINib(nibName: CellNibs.recipeCell, bundle: nil), forCellReuseIdentifier: CellNibs.recipeCell)
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        searchBar.delegate = self
        setupUI()
        DataHelper.shared.loadPredefinedRecipes { recipes in
            self.searchResults = recipes
        }
       


    }
    
    private func setupUI() {
        configureNextButton()
        recipesTableView.tableFooterView = UIView()
        recipesTableView.separatorStyle = .none
        recipesTableView.rowHeight = 179
        searchLabel.isHidden = true
        resultsLabel.isHidden = true
    }
    
    private func configureNextButton() {
        if Event.shared.selectedRecipes.isEmpty {
                 nextButton.setTitle("Skip", for: .normal)
             } else {
                 let recipesCount = String(Event.shared.selectedRecipes.count)
                 nextButton.setTitle("Next (\(recipesCount))", for: .normal)
             }
    }
    
    func showSearchProgress(_ bool: Bool) {
        if bool {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        recipesTableView.isHidden = bool
        searchLabel.isHidden = !bool
    }
    
    @IBAction func didTapPrevious(_ sender: UIButton) {
        delegate?.recipeVCDidTapPrevious(controller: self)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        delegate?.recipeVCDidTapNext(controller: self)
    }
    



}

extension RecipesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipesTableView.dequeueReusableCell(withIdentifier: CellNibs.recipeCell, for: indexPath) as! RecipeCell
        let recipe = searchResults[indexPath.section]
        var isSelected = false
        if Event.shared.selectedRecipes.contains(where: { $0.uri == recipe.uri! }) {
            isSelected = true
        }
        cell.configureCell(recipe: recipe, isSelected: isSelected)
        cell.recipeCellDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = searchResults[indexPath.section]
        let recipeDetailsVC = RecipeDetailsViewController()
        recipeDetailsVC.selectedRecipe = recipe
        recipeDetailsVC.delegate = self
        present(recipeDetailsVC, animated: true, completion: nil)
    }
    
    
}

extension RecipesViewController: RecipeCellDelegate {
    func recipeCellDidSelectRecipe(recipe: Recipe) {
        if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.uri == recipe.uri! }) {
            Event.shared.selectedRecipes.remove(at: index)
        } else {
            Event.shared.selectedRecipes.append(recipe)
        }
        configureNextButton()
    }
    
    
}

extension RecipesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            DataHelper.shared.loadPredefinedRecipes { recipes in
                self.searchResults = recipes
            }
            return
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        DataHelper.shared.loadSearchedRecipes(keyword: keyword, display: showSearchProgress(_:)) { recipes in
            self.showSearchProgress(false)
            self.searchResults = recipes
        }
        
    }
    
    
    
}

extension RecipesViewController: RecipeDetailsViewControllerDelegate {
    func recipeDetailsVCShouldDismiss(_ controller: RecipeDetailsViewController) {
        recipesTableView.reloadData()
        configureNextButton()
    }
    
    
}
