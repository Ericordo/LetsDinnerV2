//
//  RecipesViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import RealmSwift

import SafariServices

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
    private let realm = try! Realm()
    
    private var searchResults = [Recipe]() {
        didSet {
            recipesTableView.reloadData()
        }
    }
    
    private var customSearchResults: Results<CustomRecipe>?
    
    private var customRecipes : Results<CustomRecipe>?
    
     var previouslySelectedRecipes = [Recipe]()
    var previouslySelectedCustomRecipes = [CustomRecipe]()
    
    private var searchType: SearchType = .apiRecipes {
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
        setupSwipeGesture()
        loadRecipes()
        
        previouslySelectedRecipes = Event.shared.selectedRecipes
        previouslySelectedCustomRecipes = Event.shared.selectedCustomRecipes
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        prepareTasks()
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
    
    private func setupSwipeGesture() {
        self.view.addSwipeGestureRecognizer(action: {self.delegate?.recipeVCDidTapPrevious(controller: self)})
    }
        
    private func updateUI() {
        switch searchType {
        case .apiRecipes:
            headerLabel.text = "DISCOVER THESE RECIPES"
            searchBar.placeholder = "Search 360K+ recipes"
            recipeToggle.setTitle("My recipes", for: .normal)
            resultsLabel.isHidden = true
            loadRecipes()
            
        case .customRecipes:
            headerLabel.text = "MY RECIPES"
            searchBar.placeholder = "Search my recipes"
            recipeToggle.setTitle("All recipes", for: .normal)
            loadCustomRecipes()
            resultsLabel.isHidden = true
        }
    }
    
    private func configureNextButton() {
        let count = Event.shared.selectedRecipes.count + Event.shared.selectedCustomRecipes.count
        if count == 0 {
            nextButton.setTitle("Skip", for: .normal)
        } else {
            nextButton.setTitle("Next (\(count))", for: .normal)
        }
    }
    
    private func loadRecipes() {
        searchResults.removeAll()
        DataHelper.shared.loadPredefinedRecipes { recipes in
            self.searchResults = recipes
            Event.shared.selectedRecipes.forEach { recipe in
                if !self.searchResults.contains(where: { comparedRecipe -> Bool in
                          comparedRecipe.id == recipe.id
                      }) {
                        self.searchResults.append(recipe)
                      }
                  }
        }
    }
    
    private func loadCustomRecipes() {
        customRecipes = realm.objects(CustomRecipe.self)
        recipesTableView.reloadData()
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
//        prepareTasks()
        delegate?.recipeVCDidTapNext(controller: self)
    }
    
    @IBAction func didTapCreateRecipe(_ sender: UIButton) {
        let recipeCreationVC = RecipeCreationViewController()
        recipeCreationVC.modalPresentationStyle = .fullScreen
        recipeCreationVC.recipeCreationVCDelegate = self
        present(recipeCreationVC, animated: true, completion: nil)
    }
    
    @IBAction func didTapRecipeToggle(_ sender: UIButton) {
        if searchType == .apiRecipes {
            searchType = .customRecipes
        } else {
            searchType = .apiRecipes
        }
    }
    
    private func prepareTasks() {
//        Event.shared.tasks.forEach { task in
//            if !task.isCustom {
//                let index = Event.shared.tasks.firstIndex { comparedTask -> Bool in
//                    comparedTask.taskName == task.taskName
//                }
//                Event.shared.tasks.remove(at: index!)
//            }
//        }
        
        Event.shared.tasks.forEach { task in
            if !task.isCustom && !Event.shared.selectedRecipes.contains(where: { recipe -> Bool in
                recipe.title == task.parentRecipe
            }) && !Event.shared.selectedCustomRecipes.contains(where: { customRecipe -> Bool in
                customRecipe.title == task.parentRecipe
            }) {
                let index = Event.shared.tasks.firstIndex { comparedTask -> Bool in
                    comparedTask.taskName == task.taskName
                }
                Event.shared.tasks.remove(at: index!)
            }
        }
        
        var newRecipes = [Recipe]()
        if previouslySelectedRecipes.count == 0 {
            newRecipes = Event.shared.selectedRecipes
        } else {
            Event.shared.selectedRecipes.forEach { recipe in
                if !previouslySelectedRecipes.contains(where: { comparedRecipe -> Bool in
                    recipe.title == comparedRecipe.title
                }) {
                    newRecipes.append(recipe)
                }
            }
        }
        
        var newCustomRecipes = [CustomRecipe]()
        if previouslySelectedCustomRecipes.count == 0 {
            newCustomRecipes = Event.shared.selectedCustomRecipes
        } else {
            Event.shared.selectedCustomRecipes.forEach { recipe in
                if !previouslySelectedCustomRecipes.contains(where: { comparedRecipe -> Bool in
                    recipe.id == comparedRecipe.id
                }) {
                    newCustomRecipes.append(recipe)
                }
            }
            
        }
        
//        let recipes = Event.shared.selectedRecipes
//        recipes.forEach { recipe in
        newRecipes.forEach { recipe in
            let recipeName = recipe.title ?? ""
            let servings = Double(recipe.servings ?? 2)
            let ingredients = recipe.ingredientList
            
            if defaults.measurementSystem == "imperial" {
                
                ingredients?.forEach({ ingredient in
                    if let name = ingredient.name?.capitalizingFirstLetter(), let amount = ingredient.usAmount, let unit = ingredient.usUnit {
                        let task = Task(taskName: name, assignedPersonUid: "nil", taskState: TaskState.unassigned.rawValue, taskUid: "nil", assignedPersonName: "nil", isCustom: false, parentRecipe: recipeName)
                        task.metricAmount = (amount * 2) / Double(servings)
                        task.metricUnit = unit
                        task.servings = 2
                        Event.shared.tasks.append(task)
                    }
                })
                
            } else {
                
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
        
//        let customRecipes = Event.shared.selectedCustomRecipes
//        customRecipes.forEach { customRecipe in
        newCustomRecipes.forEach { customRecipe in
            let recipeName = customRecipe.title
            let servings = Double(customRecipe.servings)
            let customIngredients = customRecipe.ingredients
            customIngredients.forEach { customIngredient in
                let task = Task(taskName: customIngredient.name, assignedPersonUid: "nil", taskState: TaskState.unassigned.rawValue, taskUid: "nil", assignedPersonName: "nil", isCustom: false, parentRecipe: recipeName)
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
        if searchType == .customRecipes && customRecipes?.count == 0 {
            tableView.setEmptyView(title: LabelStrings.noCustomRecipeTitle, message: LabelStrings.noCustomRecipeMessage)
        } else {
            tableView.restore()
        }
        
        switch searchType {
        case.apiRecipes:
            return searchResults.count
        case.customRecipes:
            return customRecipes!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipesTableView.dequeueReusableCell(withIdentifier: CellNibs.recipeCell, for: indexPath) as! RecipeCell
        switch searchType {
        case .apiRecipes:
            let recipe = searchResults[indexPath.section]
            var isSelected = false
            if Event.shared.selectedRecipes.contains(where: { $0.title == recipe.title }) {
                isSelected = true
            }
            cell.configureCell(recipe: recipe, isSelected: isSelected, searchType: searchType)
        case .customRecipes:
            if let customRecipe = customRecipes?[indexPath.section] {
                var isSelected = false
                if Event.shared.selectedCustomRecipes.contains(where: { $0.id == customRecipe.id }) {
                    isSelected = true
                }
                cell.configureCellWithCustomRecipe(customRecipe: customRecipe, isSelected: isSelected, searchType: searchType)
            }
        }
        cell.recipeCellDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch searchType {
        case .apiRecipes:
            let recipe = searchResults[indexPath.section]
            openRecipeInSafari(recipe: recipe)
        case .customRecipes:
            guard let recipes = customRecipes else { return }
            let recipe = recipes[indexPath.section]
            let customRecipeDetailsVC = CustomRecipeDetailsViewController()
            customRecipeDetailsVC.modalPresentationStyle = .fullScreen
            customRecipeDetailsVC.selectedRecipe = recipe
            customRecipeDetailsVC.customRecipeDetailsDelegate = self
            present(customRecipeDetailsVC, animated: true, completion: nil)
        }
    }
    
    private func openRecipeInSafari(recipe: Recipe) {
        guard let sourceUrl = recipe.sourceUrl else { return }
        if let url = URL(string: sourceUrl) {
            let vc = SFSafariViewController(url: url)
            vc.preferredControlTintColor = Colors.newGradientRed
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func loadSearchResult(recipeId: Int) {
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
    func recipeCellDidSelectCustomRecipe(customRecipe: CustomRecipe) {
        if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == customRecipe.id }) {
            Event.shared.selectedCustomRecipes.remove(at: index)
        } else {
            Event.shared.selectedCustomRecipes.append(customRecipe)
        }
        configureNextButton()
    }
    
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
        resultsLabel.isHidden = true
        switch searchType {
        case .apiRecipes:
            guard !searchText.isEmpty else {
                DataHelper.shared.loadPredefinedRecipes { recipes in
                    self.searchResults = recipes
                }
                return
            }
        case .customRecipes:
            guard !searchText.isEmpty else {
                loadCustomRecipes()
                resultsLabel.isHidden = true
                recipesTableView.isHidden = false
                return
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        
        switch searchType {
        case .apiRecipes:
            searchResults.removeAll()
            DataHelper.shared.getSearchedRecipesIds(keyword: keyword, display: showSearchProgress(_:)) { [weak self] result in
                   
                   switch result {
                   case.success(let recipeIds):
                       self?.showSearchProgress(false)
                       if recipeIds.isEmpty {
                        self?.resultsLabel.isHidden = false
                       }
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
        case .customRecipes:
            customRecipes = customRecipes?.filter("title CONTAINS[cd] %@", keyword)
            recipesTableView.reloadData()
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

extension RecipesViewController: RecipeCreationVCDelegate {
    func recipeCreationVCDidTapDone() {
        loadCustomRecipes()
    }
}

extension RecipesViewController: CustomRecipeDetailsVCDelegate {    
    func customrecipeDetailsVCShouldDismiss() {
        recipesTableView.reloadData()
        configureNextButton()
        StepStatus.currentStep = .recipesVC
    }
    
    func didDeleteCustomRecipe() {
        recipesTableView.reloadData()
        configureNextButton()
    }
    


    
}
