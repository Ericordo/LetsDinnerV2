//
//  RecipesViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices
import ReactiveCocoa
import ReactiveSwift

protocol ModalViewHandler: class {
    func reloadTableAfterModalDismissed()
}

protocol RecipesViewControllerDelegate: class {
        func recipeVCDidTapNext()
        func recipeVCDidTapPrevious()
}

class RecipesViewController: LDNavigationViewController {
    // MARK: Properties
    private let searchBar = LDSearchBar()
    
    private let headerLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let recipesTableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 120
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        return tableView
    }()
    
    private let toolbar = RecipesToolbar()
    
    private let loadingView = LDLoadingView()
    
    weak var delegate: RecipesViewControllerDelegate?
    
    private let viewModel: RecipesViewModel

    // MARK: Init
    init(viewModel: RecipesViewModel, delegate: RecipesViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StepStatus.currentStep = .recipesVC
    }
    

    
    
    // MARK: ViewModel Binding
    private func bindViewModel() {
        navigationBar.previousButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.delegate?.recipeVCDidTapPrevious()
        }
        
        navigationBar.nextButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.viewModel.prepareTasks()
            #warning("To avoid glitching during transition, check on real device if really necessary")
            self.toolbar.removeFromSuperview()
            self.delegate?.recipeVCDidTapNext()
        }
        
        toolbar.createRecipeButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            
            let isAnimated = defaults.bool(forKey: Keys.createCustomRecipeWelcomeVCVisited)
            self.presentRecipeCreationVC(animated: isAnimated)
        }
        
        toolbar.selectedRecipesButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            let selectedRecipesVC = SelectedRecipesViewController()
            selectedRecipesVC.modalPresentationStyle = .fullScreen
            selectedRecipesVC.dismissDelegate = self
            self.present(selectedRecipesVC, animated: true, completion: nil)
        }
        
        toolbar.recipeToggle.reactive.controlEvents(.touchUpInside).observeValues { _ in
            let currentSearchType = self.viewModel.searchType.value
            self.viewModel.searchType.value = currentSearchType == .apiRecipes ? .customRecipes : .apiRecipes
        }
        
        searchBar.reactive.continuousTextValues.observeValues { text in
            guard let text = text, text.isEmpty else { return }
            self.viewModel.loadRecipes()
        }
        
        searchBar.reactive.searchButtonClicked.observeValues { _ in
            self.searchBar.resignFirstResponder()
            guard let keyword = self.searchBar.text else { return }
            self.viewModel.keyword.value = keyword
        }
        
        self.viewModel.searchType.producer
        .observe(on: UIScheduler())
        .take(duringLifetimeOf: self)
        .startWithValues { [weak self] searchType in
            guard let self = self else { return }
            self.updateUI(searchType)
        }
        
        self.viewModel.isLoading.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.view.addSubview(self.loadingView)
                    self.loadingView.snp.makeConstraints { make in
                        make.leading.trailing.equalToSuperview()
                        make.top.equalTo(self.recipesTableView.snp.top)
                        make.bottom.equalTo(self.toolbar.snp.top)
                    }
                    self.loadingView.start()
                } else {
                    self.loadingView.stop()
                }
        }

        self.viewModel.dataChangeSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [weak self] in
                guard let self = self else { return }
                self.recipesTableView.reloadData()
                self.configureNextAndSelectedRecipesButtons()
        }
        
        self.viewModel.errorSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [weak self] error in
                guard let self = self else { return }
                self.showError(error)
        }
        
       
    }
        
    // MARK: Methods
    private func updateUI(_ searchType: SearchType) {
        switch searchType {
        case .apiRecipes:
            headerLabel.text = LabelStrings.discoverRecipes
            searchBar.placeholder = LabelStrings.searchApiRecipes
            toolbar.recipeToggle.setImage(Images.recipeBookButtonOutlined, for: .normal)
        case .customRecipes:
            headerLabel.text = LabelStrings.yourRecipes
            searchBar.placeholder = LabelStrings.searchMyRecipes
            toolbar.recipeToggle.setImage(Images.discoverButtonOutlined, for: .normal)
        }
        self.viewModel.loadRecipes()
        animateSearchTypeTransition()
        searchBar.text = ""
    }

    private func animateSearchTypeTransition() {
        UIView.transition(with: self.view,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    private func openRecipeInSafari(_ recipe: Recipe) {
        guard let sourceUrl = recipe.sourceUrl else { return }
        if let url = URL(string: sourceUrl) {
            let vc = CustomSafariVC(url: url)
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func configureNextAndSelectedRecipesButtons() {
        let count = Event.shared.selectedRecipes.count + Event.shared.selectedCustomRecipes.count
        let nextTitle = count == 0 ? LabelStrings.skip : LabelStrings.next
        navigationBar.nextButton.setTitle(nextTitle, for: .normal)
        let selectedRecipesTitle = count == 0 ? "" : " (\(count))"
        toolbar.selectedRecipesButton.setTitle(selectedRecipesTitle, for: .normal)
    }
    
    private func updateState() {
        recipesTableView.reloadData()
        configureNextAndSelectedRecipesButtons()
        StepStatus.currentStep = .recipesVC
    }
    
    private func showError(_ error: ApiError) {
        #warning("Improve error messages")
        switch error {
        case .decodingFailed:
            self.showBasicAlert(title: AlertStrings.decodingFailed, message: "")
        case .noNetwork:
            self.showBasicAlert(title: AlertStrings.noNetwork, message: "")
        case.requestLimit:
            self.showBasicAlert(title: AlertStrings.requestLimit, message: AlertStrings.tryAgain)
        }
    }
    
    private func setupTableView() {
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        recipesTableView.register(UINib(nibName: CellNibs.recipeCell, bundle: nil),
                                  forCellReuseIdentifier: CellNibs.recipeCell)
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        navigationBar.titleLabel.text = LabelStrings.chooseRecipes
        navigationBar.previousButton.setImage(Images.chevronLeft, for: .normal)
        navigationBar.previousButton.setTitle(LabelStrings.details, for: .normal)
        view.addSwipeGestureRecognizer(action: { self.delegate?.recipeVCDidTapPrevious() })
        view.addTapGestureToHideKeyboard()
        view.addSubview(searchBar)
        view.addSubview(headerLabel)
        view.addSubview(recipesTableView)
        view.addSubview(toolbar)
        configureNextAndSelectedRecipesButtons()
        addConstraints()
    }
    
    
    private func addConstraints() {
        searchBar.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.top.equalTo(self.navigationBar.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(17)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(17)
            make.height.equalTo(18)
        }
        
        recipesTableView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
        
        let height = UIDevice.current.hasHomeButton ? 60 : 83
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(height)
        }
    }
    
    private func presentRecipeCreationVC(animated: Bool) {
        let recipeCreationVC = RecipeCreationViewController(viewModel: RecipeCreationViewModel())
        recipeCreationVC.modalPresentationStyle = .fullScreen
        recipeCreationVC.editingMode = true
        recipeCreationVC.recipeCreationVCDelegate = self
        self.present(recipeCreationVC, animated: animated, completion: nil)
    }
}
    //MARK: TableView Delegate
extension RecipesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .backgroundColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch viewModel.searchType.value {
        case .apiRecipes:
            viewModel.recipes.isEmpty ? tableView.setEmptyViewForNoResults() : tableView.restore()
            return viewModel.recipes.count
        case .customRecipes:
            if viewModel.customRecipes.count == 0 {
                if searchBar.text!.isEmpty {
                                tableView.setEmptyViewForRecipeView(title: LabelStrings.noCustomRecipeTitle, message: LabelStrings.noCustomRecipeMessage)
                } else {
                    tableView.setEmptyViewForNoResults()
                }
            } else {
                tableView.restore()
            }
            return viewModel.customRecipes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipesTableView.dequeueReusableCell(withIdentifier: CellNibs.recipeCell, for: indexPath) as! RecipeCell
        switch viewModel.searchType.value {
        case .apiRecipes:
            let recipe = viewModel.recipes[indexPath.section]
            cell.configureCell(recipe)
        case .customRecipes:
            let customRecipe = viewModel.customRecipes[indexPath.section]
            cell.configureCellWithCustomRecipe(customRecipe)
        }
        cell.recipeCellDelegate = self
        return cell
    }
}

    //MARK: RecipeCreationVC Delegate
extension RecipesViewController: RecipeCreationVCDelegate {
    func recipeCreationVCDidTapDone() {
        self.viewModel.searchType.value = .customRecipes
    }
}

//MARK: ModalViewHandler
extension RecipesViewController: ModalViewHandler {
    func reloadTableAfterModalDismissed() {
        updateState()
    }
}

    //MARK: RecipeCell Delegate
extension RecipesViewController: RecipeCellDelegate {
    func recipeCellDidSelectView(_ recipe: Recipe) {
        openRecipeInSafari(recipe)
    }
    
    func recipeCellDidSelectCustomRecipeView(_ customRecipe: LDRecipe) {
//        let customRecipeDetailsVC = CustomRecipeDetailsViewController(viewModel: CustomRecipeDetailsViewModel())
//        customRecipeDetailsVC.modalPresentationStyle = .fullScreen
//        customRecipeDetailsVC.selectedRecipe = customRecipe
//        customRecipeDetailsVC.customRecipeDetailsDelegate = self
//
//        present(customRecipeDetailsVC, animated: true, completion: nil)
        
        let viewCustomRecipeVC = RecipeCreationViewController(viewModel: RecipeCreationViewModel())
        viewCustomRecipeVC.modalPresentationStyle = .overFullScreen
        viewCustomRecipeVC.recipeCreationVCDelegate = self
        viewCustomRecipeVC.recipeToEdit = customRecipe
        viewCustomRecipeVC.viewExistingRecipe = true
        self.present(viewCustomRecipeVC, animated: true, completion: nil)
    }
    
    func recipeCellDidSelectCustomRecipe(_ customRecipe: LDRecipe) {
        if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == customRecipe.id }) {
            
            CustomOrderHelper.shared.removeRecipeCustomOrder(recipeId: customRecipe.id)
            Event.shared.selectedCustomRecipes.remove(at: index)
        } else {
            Event.shared.selectedCustomRecipes.append(customRecipe)
            
            CustomOrderHelper.shared.assignRecipeCustomOrder(recipeId: customRecipe.id, order: CustomOrderHelper.shared.lastIndex + 1)
        }
        configureNextAndSelectedRecipesButtons()
    }
    
    // MARK: Append Recipe to EventArray
    func recipeCellDidSelectRecipe(_ recipe: Recipe) {
        if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.id == recipe.id! }) {
            
            CustomOrderHelper.shared.removeRecipeCustomOrder(recipeId: String(recipe.id!))
            Event.shared.selectedRecipes.remove(at: index)
        } else {
            Event.shared.selectedRecipes.append(recipe)
            
            CustomOrderHelper.shared.assignRecipeCustomOrder(recipeId: String(recipe.id!), order: CustomOrderHelper.shared.lastIndex + 1)
        }
        configureNextAndSelectedRecipesButtons()
    }
}

    //MARK: CustomRecipeDetailsVCDelegate
extension RecipesViewController: CustomRecipeDetailsVCDelegate {
    func customRecipeDetailsVCShouldDismiss() {
        updateState()
    }
    
    func didDeleteCustomRecipe() {
        self.viewModel.searchType.value = .customRecipes
        updateState()
    }
}


