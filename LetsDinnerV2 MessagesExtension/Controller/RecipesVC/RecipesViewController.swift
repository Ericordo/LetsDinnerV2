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

protocol ModalViewHandler: class {
    func reloadTableAfterModalDismissed()
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
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var createRecipeButton: UIButton!
    @IBOutlet weak var recipeToggle: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedRecipeButton: UIButton!
    
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

    // MARK: - Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .recipesVC

        recipesTableView.register(UINib(nibName: CellNibs.recipeCell, bundle: nil), forCellReuseIdentifier: CellNibs.recipeCell)
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        searchBar.delegate = self

        configureUI()
        setupGesture()
        loadRecipes()
        
        previouslySelectedRecipes = Event.shared.selectedRecipes
        previouslySelectedCustomRecipes = Event.shared.selectedCustomRecipes
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.post(name: Notification.Name("didGoToNextStep"), object: nil, userInfo: ["step": 2])
        
        // Cache searchtype
        if let currentRecipeMenu = StepStatus.currentRecipeMenu {
            searchType = currentRecipeMenu
        }
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
//        prepareTasks()
    }
    
    private func configureUI() {
        configureNextButton()
        configureSelectedRecipeButton()
        
        recipesTableView.tableFooterView = UIView()
        recipesTableView.separatorStyle = .none
        recipesTableView.rowHeight = 120
        recipesTableView.showsVerticalScrollIndicator = false
        
        searchLabel.isHidden = true
        resultsLabel.isHidden = true
        
        if UIDevice.current.hasHomeButton {
            bottomViewHeightConstraint.constant = 60
            self.bottomView.layoutIfNeeded()
        }
        
        bottomView.backgroundColor = UIColor.backgroundColor.withAlphaComponent(0.4)
        bottomView.addBlurEffect()
    }
    
    private func setupGesture() {
        self.view.addSwipeGestureRecognizer(action: {self.delegate?.recipeVCDidTapPrevious(controller: self)})
        self.view.addTapGestureToHideKeyboard()
    }
        
    private func updateUI() {
        switch searchType {
        case .apiRecipes:
            headerLabel.text = "DISCOVER THESE RECIPES"
            searchBar.placeholder = "Search 360K+ recipes"
            recipeToggle.setImage(UIImage(named: "recipeBookButtonOutlined.png"), for: .normal)
            resultsLabel.isHidden = true
            loadRecipes()
            
        case .customRecipes:
            headerLabel.text = "YOUR RECIPES"
            searchBar.placeholder = "Search my recipes"
            recipeToggle.setImage(UIImage(named: "discoverButtonOutlined.png"), for: .normal)
            loadCustomRecipes()
            resultsLabel.isHidden = true
        }
    }
    
    private func configureNextButton() {
        let count = Event.shared.selectedRecipes.count + Event.shared.selectedCustomRecipes.count
        count == 0 ? nextButton.setTitle("Skip", for: .normal) : nextButton.setTitle("Next", for: .normal)

    }
    
    private func configureSelectedRecipeButton() {
        let count = Event.shared.selectedRecipes.count + Event.shared.selectedCustomRecipes.count
        selectedRecipeButton.contentVerticalAlignment = .center
        if count == 0 {
            selectedRecipeButton.setTitle("", for: .normal)
        } else {
            selectedRecipeButton.setTitle(" (\(count))", for: .normal)
        }
    }
    
    
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.showSearchProgress(false)
    }
    
    private func showSearchProgress(_ bool: Bool) {
        if bool {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        recipesTableView.isHidden = bool
        searchLabel.isHidden = !bool
    }
    
    // MARK: Button Tapped
    
    @IBAction func didTapPrevious(_ sender: UIButton) {
        delegate?.recipeVCDidTapPrevious(controller: self)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        prepareTasks()
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
            StepStatus.currentRecipeMenu = .customRecipes
            
            UIView.transition(with: self.view,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
            
        } else {
            searchType = .apiRecipes
            StepStatus.currentRecipeMenu = .apiRecipes
            
            UIView.transition(with: self.view,
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: nil,
                                completion: nil)
        }
    }
    
    @IBAction func didTapSelectedRecipes(_ sender: Any) {
        let selectedRecipesVC = SelectedRecipesViewController()
        selectedRecipesVC.modalPresentationStyle = .fullScreen
        selectedRecipesVC.dismissDelegate = self
        present(selectedRecipesVC, animated: true, completion: nil)
    }
    
    // MARK: Data Management
    
    private func loadRecipes() {
        searchResults.removeAll()
        
        DataHelper.shared.loadPredefinedRecipes { recipes in
            
            DispatchQueue.main.async {
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
    }
    
    private func loadCustomRecipes() {
        customRecipes = realm.objects(CustomRecipe.self)
        recipesTableView.reloadData()
    }
    
    func prepareTasks() {
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
        
        // New Recipes
        var newRecipes = [Recipe]()
        
        if previouslySelectedRecipes.isEmpty {
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
                
        if previouslySelectedCustomRecipes.isEmpty {
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
    }
}

extension RecipesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.backgroundColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchType == .customRecipes && customRecipes?.count == 0 {
            tableView.setEmptyViewForRecipeView(title: LabelStrings.noCustomRecipeTitle, message: LabelStrings.noCustomRecipeMessage)
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
    
    
    // TODO: - Delete before release if we decide to keep the View button
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch searchType {
//        case .apiRecipes:
//            let recipe = searchResults[indexPath.section]
//            openRecipeInSafari(recipe: recipe)
//        case .customRecipes:
//            guard let recipes = customRecipes else { return }
//            let recipe = recipes[indexPath.section]
//            let customRecipeDetailsVC = CustomRecipeDetailsViewController()
//            customRecipeDetailsVC.modalPresentationStyle = .fullScreen
//            customRecipeDetailsVC.selectedRecipe = recipe
//            customRecipeDetailsVC.customRecipeDetailsDelegate = self
//            present(customRecipeDetailsVC, animated: true, completion: nil)
//        }
//    }
    
    private func openRecipeInSafari(recipe: Recipe) {
        guard let sourceUrl = recipe.sourceUrl else { return }
        if let url = URL(string: sourceUrl) {
            let vc = CustomSafariVC(url: url)

//            vc.registerForNotification()
//            vc.preferredControlTintColor = UIColor.activeButton
//            vc.preferredBarTintColor = Colors.paleGray
//            vc.dismissButtonStyle = .close
//            vc.modalPresentationStyle = .overFullScreen
            
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
    func recipeCellDidSelectView(recipe: Recipe) {
        openRecipeInSafari(recipe: recipe)
    }
    
    func recipeCellDidSelectCustomRecipeView(customRecipe: CustomRecipe) {
        let customRecipeDetailsVC = CustomRecipeDetailsViewController()
        customRecipeDetailsVC.modalPresentationStyle = .fullScreen
        customRecipeDetailsVC.selectedRecipe = customRecipe
        customRecipeDetailsVC.customRecipeDetailsDelegate = self

        present(customRecipeDetailsVC, animated: true, completion: nil)
    }
    
    func recipeCellDidSelectCustomRecipe(customRecipe: CustomRecipe) {
        
        if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == customRecipe.id }) {
            // Re-assign the customOrder
            Event.shared.reassignCustomOrderAfterRemoval(recipeType: .customRecipes, index: index)
            Event.shared.selectedCustomRecipes.remove(at: index)
            
            
        } else {
            Event.shared.selectedCustomRecipes.append(customRecipe)
            
            // Assign Order
            guard let lastIndex = Event.shared.findTheIndexOfLastCustomOrderFromAllRecipes() else {return}
            Event.shared.selectedCustomRecipes[Event.shared.selectedCustomRecipes.count - 1].assignCustomOrder(customOrder: (lastIndex + 1))
            
        }
        configureNextButton()
        configureSelectedRecipeButton()
    }
    
    // MARK: Append Recipe to EventArray
    func recipeCellDidSelectRecipe(recipe: Recipe) {
        if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.id == recipe.id! }) {
            Event.shared.reassignCustomOrderAfterRemoval(recipeType: .apiRecipes, index: index)
            Event.shared.selectedRecipes.remove(at: index)
        } else {
            
            Event.shared.selectedRecipes.append(recipe)
            
            // Assign Order
            guard let lastIndex = Event.shared.findTheIndexOfLastCustomOrderFromAllRecipes() else {return}
            Event.shared.selectedRecipes[Event.shared.selectedRecipes.count - 1].assignCustomOrder(customOrder: (lastIndex + 1))
//            print("lastitem:\(lastIndex)")
//            print(Event.shared.selectedRecipes.count)
//
//            print("After Append = \(Event.shared.findTheLastNumberFromAllRecipes())")
            
            
        }
        configureNextButton()
        configureSelectedRecipeButton()
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
        resultsLabel.isHidden = true

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
        configureSelectedRecipeButton()
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
        configureSelectedRecipeButton()
        StepStatus.currentStep = .recipesVC
    }
    
    func didDeleteCustomRecipe() {
        recipesTableView.reloadData()
        configureNextButton()
        configureSelectedRecipeButton()
    }
}

extension RecipesViewController: ModalViewHandler {
    func reloadTableAfterModalDismissed() {
        recipesTableView.reloadData()
        configureNextButton()
        configureSelectedRecipeButton()
    }
}
