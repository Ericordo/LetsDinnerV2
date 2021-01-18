//
//  RecipesViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SafariServices
import ReactiveCocoa
import ReactiveSwift
import FirebaseAnalytics

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
        return tableView
    }()
    
    private let loadingIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .activeButton
        return indicator
    }()
    
    private let toolbar = RecipesToolbar()
    
    private let loadingView = LDLoadingView()
    
    weak var delegate: RecipesViewControllerDelegate?
    
    private let viewModel: RecipesViewModel
    
    private let toolbarHeight: CGFloat = UIDevice.current.type == .iPad ? 90 : (UIDevice.current.hasHomeButton ? 60 : 75)

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
            self.delegate?.recipeVCDidTapNext()
        }
        
        toolbar.createRecipeButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.viewModel.openRecipeCreationVCIfPossible()
        }
        
        toolbar.selectedRecipesButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            let selectedRecipesVC = SelectedRecipesViewController(viewModel: SelectedRecipesViewModel(),
                                                                  dismissDelegate: self)
            selectedRecipesVC.modalPresentationStyle = .overFullScreen
            self.present(selectedRecipesVC, animated: true, completion: nil)
        }
        
        toolbar.apiRecipesButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            guard self.viewModel.searchType.value != .apiRecipes else { return }
            self.viewModel.searchType.value = .apiRecipes
        }
        
        toolbar.myRecipesButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            guard self.viewModel.searchType.value != .customRecipes else { return }
            self.viewModel.searchType.value = .customRecipes
        }
        
        toolbar.publicRecipesButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            guard self.viewModel.searchType.value != .publicRecipes else { return }
            self.viewModel.searchType.value = .publicRecipes
        }
        
        searchBar.reactive.continuousTextValues.observeValues { text in
            guard let text = text, text.isEmpty else { return }
            self.viewModel.keyword.value = ""
            self.viewModel.loadRecipes()
        }
        
        searchBar.reactive.searchButtonClicked.observeValues { _ in
            Analytics.logEvent("\(self.viewModel.searchType.value.rawValue)_search", parameters: nil)
            self.searchBar.resignFirstResponder()
            guard let keyword = self.searchBar.text?.lowercased() else { return }
            self.viewModel.keyword.value = keyword
        }
        
        self.viewModel.createRecipeSignal
        .observe(on: UIScheduler())
        .take(duringLifetimeOf: self)
        .observeValues { [weak self] _ in
            guard let self = self else { return }
            Analytics.logEvent("create_recipe", parameters: nil)
            let isAnimated = defaults.bool(forKey: Keys.recipeOnboardingComplete)
            self.presentRecipeCreationVC(animated: isAnimated)
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
        
        self.viewModel.isloadingNextRecipes.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.view.addSubview(self.loadingIndicator)
                    self.loadingIndicator.snp.makeConstraints { make in
                        make.centerX.centerY.equalToSuperview()
                    }
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.removeFromSuperview()
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
                if error == .apiRequestLimit {
                    Analytics.logEvent("api_limit_reached", parameters: nil)
                }
                self.showBasicAlert(title: AlertStrings.oops,
                                    message: error.description)
        }
    }
        
    // MARK: Methods
    private func updateUI(_ searchType: SearchType) {
        toolbar.updateTintColor(searchType)
        searchBar.text = ""
        switch searchType {
        case .apiRecipes:
            headerLabel.text = LabelStrings.discoverRecipes
            searchBar.placeholder = LabelStrings.searchApiRecipes
        case .customRecipes:
            headerLabel.text = LabelStrings.yourRecipes
            searchBar.placeholder = LabelStrings.searchMyRecipes
        case .publicRecipes:
            headerLabel.text = LabelStrings.publicRecipes
            searchBar.placeholder = LabelStrings.searchPublicRecipes
        }
        animateSearchTypeTransition()
        self.viewModel.loadRecipes()
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
        let count = Event.shared.recipesCount
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
    
    private func setupTableView() {
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        recipesTableView.register(RecipeCell.self,
                                  forCellReuseIdentifier: RecipeCell.reuseID)
        recipesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.toolbarHeight, right: 0)
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        navigationBar.titleLabel.text = LabelStrings.chooseRecipes
        navigationBar.previousButton.setImage(Images.chevronLeft, for: .normal)
        navigationBar.previousButton.setTitle(LabelStrings.details, for: .normal)
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
        
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(toolbarHeight)
        }
    }
    
    private func presentRecipeCreationVC(animated: Bool) {
        let recipeCreationVC = RecipeCreationViewController(viewModel: RecipeCreationViewModel(creationMode: true),
                                                            delegate: self)
        recipeCreationVC.modalPresentationStyle = .overFullScreen
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
                    tableView.setEmptyViewForRecipeView(title: LabelStrings.noCustomRecipeTitle,
                                                        message: LabelStrings.noCustomRecipeMessage)
                } else {
                    tableView.setEmptyViewForNoResults()
                }
            } else {
                tableView.restore()
            }
            return viewModel.customRecipes.count
        case .publicRecipes:
            if viewModel.publicRecipes.count == 0 {
                if searchBar.text!.isEmpty {
                    tableView.setEmptyViewForRecipeView(title: LabelStrings.noPublicRecipeTitle,
                                                        message: LabelStrings.noPublicRecipeMessage)
                } else {
                    tableView.setEmptyViewForNoResults()
                }
            } else {
                tableView.restore()
            }
            return viewModel.publicRecipes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipesTableView.dequeueReusableCell(withIdentifier: RecipeCell.reuseID, for: indexPath) as! RecipeCell
        switch viewModel.searchType.value {
        case .apiRecipes:
            let recipe = viewModel.recipes[indexPath.section]
            cell.configureCell(recipe)
        case .customRecipes:
            let customRecipe = viewModel.customRecipes[indexPath.section]
            cell.configureCellWithCustomRecipe(customRecipe)
        case .publicRecipes:
            let publicRecipe = viewModel.publicRecipes[indexPath.section]
            cell.configureCellWithPublicRecipe(publicRecipe)
        }
        cell.recipeCellDelegate = self
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard self.viewModel.searchType.value == .publicRecipes else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height {
            let keyword = self.viewModel.keyword.value
            if keyword.isEmpty {
                self.viewModel.loadFollowingPublicRecipes()
            } else {
                self.viewModel.searchFollowingPublicRecipes(keyword)
            }
        }
    }
}

    //MARK: RecipeCreationVC Delegate
extension RecipesViewController: RecipeCreationVCDelegate {
    func recipeCreationVCDidTapDone(creationMode: Bool) {
        if creationMode {
            self.viewModel.searchType.value = .customRecipes
        }
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
    
    func recipeCellDidSelectCustomRecipeView(_ recipe: LDRecipe) {
        let viewCustomRecipeVC = RecipeCreationViewController(viewModel: RecipeCreationViewModel(with: recipe,
                                                                                                 creationMode: false),
                                                                                                 delegate: self)
        viewCustomRecipeVC.modalPresentationStyle = .overFullScreen
        self.present(viewCustomRecipeVC, animated: true, completion: nil)
    }
        
    func recipeCellDidSelectCustomRecipe(_ customRecipe: LDRecipe) {
        if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == customRecipe.id }) {
            CustomOrderHelper.shared.removeRecipeCustomOrder(recipeId: customRecipe.id)
            Event.shared.selectedCustomRecipes.remove(at: index)
        } else {
            Event.shared.selectedCustomRecipes.append(customRecipe)
            CustomOrderHelper.shared.assignRecipeCustomOrder(recipeId: customRecipe.id,
                                                             order: CustomOrderHelper.shared.newIndex)
        }
        configureNextAndSelectedRecipesButtons()
    }
    
    func recipeCellDidSelectPublicRecipe(_ publicRecipe: LDRecipe) {
        if let index = Event.shared.selectedPublicRecipes.firstIndex(where: { $0.id == publicRecipe.id }) {
            CustomOrderHelper.shared.removeRecipeCustomOrder(recipeId: publicRecipe.id)
            Event.shared.selectedPublicRecipes.remove(at: index)
        } else {
            Event.shared.selectedPublicRecipes.append(publicRecipe)
            CustomOrderHelper.shared.assignRecipeCustomOrder(recipeId: publicRecipe.id,
                                                             order: CustomOrderHelper.shared.newIndex)
        }
        configureNextAndSelectedRecipesButtons()
    }
    
    func recipeCellDidSelectRecipe(_ recipe: Recipe) {
        if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.id == recipe.id }) {
            CustomOrderHelper.shared.removeRecipeCustomOrder(recipeId: recipe.id)
            Event.shared.selectedRecipes.remove(at: index)
        } else {
            Event.shared.selectedRecipes.append(recipe)
            CustomOrderHelper.shared.assignRecipeCustomOrder(recipeId: recipe.id,
                                                             order: CustomOrderHelper.shared.newIndex)
        }
        configureNextAndSelectedRecipesButtons()
    }
}
