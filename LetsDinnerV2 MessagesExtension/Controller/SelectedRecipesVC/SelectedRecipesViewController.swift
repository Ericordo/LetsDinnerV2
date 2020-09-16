//
//  SelectedRecipesViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 13/09/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SafariServices
import MobileCoreServices
import ReactiveSwift

class SelectedRecipesViewController: UIViewController {
    
    private let navigationView = UIView()
    
    private lazy var titleSeparator = separator()
    
    private let doneButton : LDNavButton = {
        let button = LDNavButton()
        button.setTitle(LabelStrings.done, for: .normal)
        button.contentHorizontalAlignment = .trailing
        return button
    }()
    
    private let headerLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor.secondaryTextLabel
        return label
    }()
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor.textLabel
        label.text = LabelStrings.selectedRecipesTitle
        return label
    }()
    
    private lazy var rearrangeTextLabel : UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: recipesTableView.frame.width , height: 15)
        label.text = LabelStrings.rearrangeRecipeLabel
        label.textColor = UIColor.secondaryTextLabel
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var deleteRecipeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 5, width: self.view.frame.width , height: 15)
        label.text = LabelStrings.deleteRecipeLabel
        label.textColor = UIColor.secondaryTextLabel
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    private let recipesTableView : UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 120
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var footerView = UIView(frame: CGRect(x: 0, y: 0, width: recipesTableView.frame.width, height: 40))
    
    weak var dismissDelegate: ModalViewHandler?
    
    private let viewModel : SelectedRecipesViewModel
    
    init(viewModel: SelectedRecipesViewModel, dismissDelegate: ModalViewHandler?) {
        self.viewModel = viewModel
        self.dismissDelegate = dismissDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StepStatus.currentStep = .selectedRecipesVC
    }
    
    private func bindViewModel() {
        doneButton.reactive
            .controlEvents(.touchUpInside)
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] _ in
                self.dismissDelegate?.reloadTableAfterModalDismissed()
                self.dismiss(animated: true, completion: nil)
        }
        
        self.viewModel.totalNumberOfRecipes.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] number in
                self.headerLabel.isHidden = number == 0
                self.recipesTableView.tableFooterView?.isHidden = self.headerLabel.isHidden
                if number > 1 {
                    self.rearrangeTextLabel.isHidden = false
                } else {
                    UIView.animate(withDuration: 0.7,
                                   delay: 0.0, options: .transitionCrossDissolve,
                                   animations: { self.rearrangeTextLabel.alpha = 0.1 },
                                   completion: { (_) in
                                    self.rearrangeTextLabel.isHidden = true})
                }
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.rearrangeTextLabel.isHidden = true
                }
                self.headerLabel.text = number > 1 ? String.localizedStringWithFormat(LabelStrings.selectedRecipesPlural, number) : String.localizedStringWithFormat(LabelStrings.selectedRecipes, number)
        }
    }
    
    private func openRecipeInSafari(recipe: Recipe) {
        guard let sourceUrl = recipe.sourceUrl else { return }
        if let url = URL(string: sourceUrl) {
            let vc = CustomSafariVC(url: url)
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        self.view.addSubview(navigationView)
        navigationView.addSubview(titleLabel)
        navigationView.addSubview(doneButton)
        navigationView.addSubview(titleSeparator)
        footerView.addSubview(deleteRecipeLabel)
        footerView.addSubview(rearrangeTextLabel)
        self.view.addSubview(headerLabel)
        self.view.addSubview(recipesTableView)
        addConstraints()
    }
    
    private func setupTableView() {
        recipesTableView.register(RecipeCell.self,
                                  forCellReuseIdentifier: RecipeCell.reuseID)
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        recipesTableView.dragInteractionEnabled = true
        recipesTableView.dragDelegate = self
        recipesTableView.tableFooterView = footerView
    }
    
    private func addConstraints() {
        navigationView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(43)
        }
        
        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-17)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        titleSeparator.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(18)
            make.top.equalTo(navigationView.snp.bottom).offset(14)
        }
        
        recipesTableView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        deleteRecipeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        
        rearrangeTextLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(deleteRecipeLabel.snp.bottom).offset(10)
        }
    }
}

extension SelectedRecipesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.totalNumberOfRecipes.value == 0 {
            tableView.setEmptyViewForRecipeView(title: LabelStrings.noRecipeTitle,
                                                message: LabelStrings.noRecipeMessage)
        } else {
            tableView.restore()
        }
        
        return self.viewModel.totalNumberOfRecipes.value
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipesTableView.dequeueReusableCell(withIdentifier: RecipeCell.reuseID, for: indexPath) as! RecipeCell
        cell.recipeCellDelegate = self
        cell.chosenButton.isUserInteractionEnabled = false
        
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Apirecipe index number = self + customrecipe index
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, complete in
            let cell = tableView.cellForRow(at: indexPath) as! RecipeCell
            switch cell.searchType {
            case .customRecipes:
                if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == cell.selectedCustomRecipe.id }) {
                    CustomOrderHelper.shared.removeRecipeCustomOrder(recipeId: Event.shared.selectedCustomRecipes[index].id)
                    Event.shared.selectedCustomRecipes.remove(at: index)
                }
            case .apiRecipes:
                if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.id == cell.selectedRecipe.id }) {
                    CustomOrderHelper.shared.removeRecipeCustomOrder(recipeId: String(Event.shared.selectedRecipes[index].id!))
                    Event.shared.selectedRecipes.remove(at: index)
                }
            }

            self.viewModel.updateTotalNumber()

            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .transitionCrossDissolve,
                           animations: {
                            cell.alpha = 0.3
                            cell.updateHeight(with: 0) },
                            completion: { (_) in
                            cell.updateHeight(with: 110)
                            self.recipesTableView.reloadData()
            })
            complete(true)
        }
        deleteAction.image = Images.deleteBin
        deleteAction.backgroundColor = UIColor.backgroundColor
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

extension SelectedRecipesViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        CustomOrderHelper.shared.reorderRecipeCustomOrder(sourceOrder: sourceIndexPath.row + 1,
                                                          destinationOrder: destinationIndexPath.row + 1)
        DispatchQueue.main.async {
            self.recipesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
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
        let viewCustomRecipeVC = RecipeCreationViewController(viewModel: RecipeCreationViewModel(with: customRecipe,
                                                                                                 creationMode: false),
                                                                                                 delegate: nil)
        viewCustomRecipeVC.modalPresentationStyle = .overFullScreen
        self.present(viewCustomRecipeVC, animated: true, completion: nil)
    }
}
