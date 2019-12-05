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

enum SearchType {
    case apiRecipes
    case customRecipes
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
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var createRecipeButton: UIButton!
    @IBOutlet weak var recipeToggle: UIButton!
    
    weak var delegate: RecipesViewControllerDelegate?
    
    var searchResults = [Recipe]() {
        didSet {
            resultsLabel.isHidden = !searchResults.isEmpty
            recipesTableView.reloadData()
        }
    }
    
    var searchType: SearchType = .apiRecipes {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .recipesVC
        recipesTableView.register(UINib(nibName: CellNibs.recipeCell, bundle: nil), forCellReuseIdentifier: CellNibs.recipeCell)
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        searchBar.delegate = self
        
        setupUI()
        loadRecipes()
        
        self.view.addSwipeGestureRecognizer(action: {self.delegate?.recipeVCDidTapPrevious(controller: self)})

    }
    
    private func setupUI() {
        configureNextButton()
        
        recipesTableView.tableFooterView = UIView()
        recipesTableView.separatorStyle = .none
        recipesTableView.rowHeight = 120
        recipesTableView.showsVerticalScrollIndicator = false
        
        searchLabel.isHidden = true
        resultsLabel.isHidden = true
        
        progressView.progressTintColor = Colors.newGradientRed
        progressView.trackTintColor = .white
        progressView.progress = 1/5
        progressView.setProgress(2/5, animated: true)
    }
    
    private func updateUI() {
        switch searchType {
        case .apiRecipes:
            headerLabel.text = "DISCOVER THESE RECIPES"
            searchBar.placeholder = "Search 360K+ recipes"
            recipeToggle.setTitle("Your recipes", for: .normal)
        case .customRecipes:
            headerLabel.text = "YOUR RECIPES"
            searchBar.placeholder = "Search your recipes"
            recipeToggle.setTitle("All recipes", for: .normal)
        }
    }
    
    private func configureNextButton() {
        if Event.shared.selectedRecipes.isEmpty {
                 nextButton.setTitle("Skip", for: .normal)
             } else {
                 let recipesCount = String(Event.shared.selectedRecipes.count)
                 nextButton.setTitle("Next (\(recipesCount))", for: .normal)
             }
        prepareTasks()
    }
    
    private func loadRecipes() {
        DataHelper.shared.loadPredefinedRecipes { recipe in
            self.searchResults.append(recipe)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.showSearchProgress(false)
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
    
    @IBAction func didTapCreateRecipe(_ sender: UIButton) {
        let recipeCreationVC = RecipeCreationViewController()
        present(recipeCreationVC, animated: true, completion: nil)
    }
    
    @IBAction func didTapRecipeToggle(_ sender: UIButton) {
        if searchType == .apiRecipes {
            searchType = .customRecipes
        } else {
            searchType = .apiRecipes
        }
    }
    
    
    
//    MARK: due to ManagementVC
    private func prepareTasks() {
        Event.shared.tasks.forEach { task in
            if !task.isCustom {
                let index = Event.shared.tasks.firstIndex { comparedTask -> Bool in
                    comparedTask.taskName == task.taskName
                }
                Event.shared.tasks.remove(at: index!)
            }
        }
        
        //        let ingredients = Event.shared.selectedRecipes.map { $0.ingredientList }
        //        ingredients.forEach { ingredientList in
        //            ingredientList?.forEach({ ingredient in
        //                Event.shared.tasks.append(Task(taskName: ingredient, assignedPersonUid: "nil", taskState: TaskState.unassigned.rawValue, taskUid: "", assignedPersonName: "nil"))
        //            })
        //        }
        
        let recipes = Event.shared.selectedRecipes
        recipes.forEach { recipe in
            let recipeName = recipe.title ?? ""
            let servings = Double(recipe.servings ?? 2)
            let ingredients = recipe.ingredientList
            ingredients?.forEach({ ingredient in
                if let name = ingredient.name?.capitalizingFirstLetter(), let amount = ingredient.metricAmount, let unit = ingredient.metricUnit {
                    let task = Task(taskName: name, assignedPersonUid: "nil", taskState: TaskState.unassigned.rawValue, taskUid: "nil", assignedPersonName: "nil", isCustom: false, parentRecipe: recipeName)
                    task.metricAmount = (amount * 2) / Double(servings)
                    task.metricUnit = unit
                    task.servings = 2
                    Event.shared.tasks.append(task)
                }
                
            })
        }
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
        if Event.shared.selectedRecipes.contains(where: { $0.id == recipe.id! }) {
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
    
    private func loadSearchResult(recipeId: Int) {
        searchResults.removeAll()
        DataHelper.shared.loadSearchResults(recipeId: recipeId, display: showSearchProgress(_:)) { [weak self] result in
            switch result {
            case.success(let recipe):
                self?.showSearchProgress(false)
                self?.searchResults.append(recipe)
            case .failure(let error):
                switch error {
                case .decodingFailed:
                    self?.showAlert(title: MessagesToDisplay.decodingFailed, message: "")
                case .noNetwork:
                    self?.showAlert(title: MessagesToDisplay.noNetwork, message: "")
                case .requestLimit:
                    self?.showAlert(title: MessagesToDisplay.requestLimit, message: MessagesToDisplay.tryAgain)
                }
            }
        }
    }
    
    
}

extension RecipesViewController: RecipeCellDelegate {
    func recipeCellDidSelectRecipe(recipe: Recipe) {
        if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.id == recipe.id! }) {
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
            DataHelper.shared.loadPredefinedRecipes { recipe in
                self.searchResults.removeAll()
                self.searchResults.append(recipe)
            }
            return
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        resultsLabel.isHidden = true
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        
//        DataHelper.shared.loadSearchedRecipes(keyword: keyword, display: showSearchProgress(_:), completion: { [weak self] result in
//            switch result {
//            case .success(let recipes):
//                self?.showSearchProgress(false)
//                self?.searchResults = recipes
//            case .failure(let error):
//                switch error {
//                case .decodingFailed:
//                    self?.showAlert(title: MessagesToDisplay.decodingFailed, message: "")
//                case .noNetwork:
//                    self?.showAlert(title: MessagesToDisplay.noNetwork, message: "")
//                case .requestLimit:
//                    self?.showAlert(title: MessagesToDisplay.requestLimit, message: MessagesToDisplay.tryAgain)
//                }
//            }
//        })
        
        DataHelper.shared.getSearchedRecipesIds(keyword: keyword, display: showSearchProgress(_:)) { [weak self] result in
            switch result {
            case.success(let recipeIds):
                self?.showSearchProgress(false)
                recipeIds.forEach { recipeId in
                    self?.loadSearchResult(recipeId: recipeId)
                }
            case .failure(let error):
                switch error {
                case .decodingFailed:
                    self?.showAlert(title: MessagesToDisplay.decodingFailed, message: "")
                case .noNetwork:
                    self?.showAlert(title: MessagesToDisplay.noNetwork, message: "")
                case .requestLimit:
                    self?.showAlert(title: MessagesToDisplay.requestLimit, message: MessagesToDisplay.tryAgain)
                }
            }
        }
    }
    
    
}


extension RecipesViewController: RecipeDetailsViewControllerDelegate {
    func recipeDetailsVCShouldDismiss(_ controller: RecipeDetailsViewController) {
        recipesTableView.reloadData()
        configureNextButton()
        StepStatus.currentStep = .recipesVC
     
    }
}
