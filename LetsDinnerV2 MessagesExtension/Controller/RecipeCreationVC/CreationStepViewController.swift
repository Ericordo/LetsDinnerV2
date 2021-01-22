//
//  CreationStepViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 17/08/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift

class CreationStepViewController: UIViewController {
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.font = .systemFont(ofSize: 13)
        label.text = self.section.title
        return label
    }()
    
    private lazy var titleSeparator = separator()
    
    lazy var textFieldView = LDListItemAdditionView(section: section)
    
    let listTableView : UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.separatorInset.left = 15
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let viewModel : RecipeCreationViewModel
    
    private let section : CreateRecipeSections
    
    private var selectedRow : Int?
    
    init(viewModel: RecipeCreationViewModel, section: CreateRecipeSections) {
        self.viewModel = viewModel
        self.section = section
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let textFieldHeight : CGFloat = self.listTableView.isEditing ? (self.section == .ingredient ? 66 : 44) : 0
        preferredContentSize.height = listTableView.contentSize.height + 22 + textFieldHeight
    }
    

    private func bindViewModel() {
        self.viewModel.ingredients.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] ingredients in
                if self.section == .ingredient {
                    self.updateTableViewLayout()
                }
        }
        
        self.viewModel.steps.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] steps in
                if self.section == .step {
                    self.updateTableViewLayout()
                }
        }
        
        self.viewModel.comments.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] comments in
                if self.section == .comment {
                    self.updateTableViewLayout()
                }
        }
        
        self.viewModel.creationMode.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] creationMode in
                self.setupCreationInterface(creationMode)
        }
        
        self.textFieldView.addButton.reactive
            .controlEvents(.touchUpInside)
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] _ in
                self.addItem()
        }
    }
    
    private func updateTableViewLayout() {
        self.listTableView.snp.updateConstraints { make in
            make.height.equalTo(CGFloat.greatestFiniteMagnitude)
        }
        self.listTableView.reloadData()
        self.listTableView.layoutIfNeeded()
        self.listTableView.snp.updateConstraints { make in
            make.height.equalTo(self.listTableView.contentSize.height)
        }
    }
    
    func setupCreationInterface(_ bool: Bool) {
        textFieldView.addButton.isHidden = !bool
        let textFieldHeight : CGFloat = bool ? (self.section == .ingredient ? 66 : 44) : 0
        self.textFieldView.snp.updateConstraints { make in
            make.height.equalTo(textFieldHeight)
        }
        self.listTableView.isEditing = bool
        self.listTableView.allowsSelectionDuringEditing = bool
    }

    private func addItem() {
        switch self.section {
        case .name:
            break
        case .ingredient:
            self.addIngredient(self.textFieldView.textField.text!, with: self.textFieldView.secondaryTextField.text!)
        case .step:
            self.addCookingStep(self.textFieldView.textField.text!)
        case .comment:
            self.addComment(self.textFieldView.textField.text!)
        }
        self.textFieldView.textField.text = ""
        self.selectedRow = nil
    }
    
    private func addIngredient(_ name: String, with amountAndUnit: String) {
        guard !name.isEmpty else {
            self.textFieldView.textField.shake()
            return
        }
        var unit : String? = ""
        var amount = ""
        
        let dividedString = amountAndUnit.trimmingCharacters(in: .whitespacesAndNewlines)
        if dividedString.hasWhiteSpace {
            let dividedStringArray = dividedString.split(separator: " ")
            amount = String(dividedStringArray[0])
            for index in 1...dividedStringArray.count - 1 {
                unit! += String(dividedStringArray[index]) + " "
            }
        } else {
            amount = amountAndUnit
        }
        
        let amountAsDouble = amount.doubleValue == 0 ? nil : amount.doubleValue
        
        if unit!.isEmpty {
            unit = nil
        }
        
        if let row = self.selectedRow {
            let selectedIngredient = self.viewModel.ingredients.value[row]
            self.viewModel.ingredients.value.remove(at: row)
            self.viewModel.ingredients.value.insert(LDIngredient(name: name,
                                                                 amount: amountAsDouble,
                                                                 unit: unit,
                                                                 recordID: selectedIngredient.recordID), at: row)
        } else {
            self.viewModel.ingredients.value.append(LDIngredient(name: name,
                                                                 amount: amountAsDouble,
                                                                 unit: unit,
                                                                 recordID: nil))
        }
        self.textFieldView.secondaryTextField.text = ""
    }
    
    private func addCookingStep(_ step: String) {
        guard !step.isEmpty else {
            self.textFieldView.textField.shake()
            return
        }
        if let row = self.selectedRow {
            self.viewModel.steps.value.remove(at: row)
            self.viewModel.steps.value.insert(step, at: row)
        } else {
            self.viewModel.steps.value.append(step)
        }
    }
    
    private func addComment(_ comment: String) {
        guard !comment.isEmpty else {
            self.textFieldView.textField.shake()
            return
        }
        if let row = self.selectedRow {
            self.viewModel.comments.value.remove(at: row)
            self.viewModel.comments.value.insert(comment, at: row)
        } else {
            self.viewModel.comments.value.append(comment)
        }
    }
    
    private func setupTableView() {
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        self.listTableView.allowsSelectionDuringEditing = false
        self.listTableView.rowHeight = UITableView.automaticDimension
        self.listTableView.estimatedRowHeight = 66
        switch self.section {
        case .name:
            break
        case .ingredient:
            listTableView.register(CreateRecipeIngredientCell.self,
                                   forCellReuseIdentifier: CreateRecipeIngredientCell.reuseID)
        case .step:
            listTableView.register(CreateRecipeCookingStepCell.self,
                                   forCellReuseIdentifier: CreateRecipeCookingStepCell.reuseID)
        case .comment:
            listTableView.register(CreateRecipeCommentCell.self,
                                   forCellReuseIdentifier: CreateRecipeCommentCell.reuseID)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(titleLabel)
        view.addSubview(titleSeparator)
        view.addSubview(listTableView)
        view.addSubview(textFieldView)
        addConstraints()
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(16)
        }
        
        titleSeparator.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        listTableView.snp.makeConstraints { make in
            make.top.equalTo(titleSeparator.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        
        textFieldView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(listTableView.snp.bottom)
        }
    }
}

extension CreationStepViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.section {
        case .name:
            return 0
        case .ingredient:
            return self.viewModel.ingredients.value.count
        case .step:
            return self.viewModel.steps.value.count
        case .comment:
            return self.viewModel.comments.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.section {
        case .name:
            return UITableViewCell()
        case .ingredient:
            let ingredientCell = tableView.dequeueReusableCell(withIdentifier: CreateRecipeIngredientCell.reuseID,
                                                               for: indexPath) as! CreateRecipeIngredientCell
            let ingredient = self.viewModel.ingredients.value[indexPath.row]
            ingredientCell.configureCell(ingredient: ingredient)
            return ingredientCell
        case .step:
            let stepCell = tableView.dequeueReusableCell(withIdentifier: CreateRecipeCookingStepCell.reuseID,
                                                         for: indexPath) as! CreateRecipeCookingStepCell
            let step =  self.viewModel.steps.value[indexPath.row]
            stepCell.configureCell(stepDetail: step,
                                   stepNumber: indexPath.row + 1)
            return stepCell
        case .comment:
            let commentCell = tableView.dequeueReusableCell(withIdentifier: CreateRecipeCommentCell.reuseID,
                                                            for: indexPath) as! CreateRecipeCommentCell
            let comment =  self.viewModel.comments.value[indexPath.row]
            commentCell.configureCell(comment: comment)
            return commentCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        switch self.section {
        case .name:
            break
        case .ingredient:
            let ingredient = self.viewModel.ingredients.value[indexPath.row]
            self.textFieldView.textField.text = ingredient.name
            if let amount = ingredient.amount {
                self.textFieldView.secondaryTextField.text = String(amount) + " \(ingredient.unit ?? "")"
            }
        case .step:
            let step = self.viewModel.steps.value[indexPath.row]
            self.textFieldView.textField.text = step
        case .comment:
            let comments = self.viewModel.comments.value[indexPath.row]
            self.textFieldView.textField.text = comments
        }
        self.textFieldView.textField.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.listTableView.isEditing {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            switch self.section {
            case .name:
                break
            case .ingredient:
                self.viewModel.ingredients.value.remove(at: indexPath.row)
            case .step:
                self.viewModel.steps.value.remove(at: indexPath.row)
            case .comment:
                self.viewModel.comments.value.remove(at: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch self.section {
        case .name:
            break
        case .ingredient:
            let movedObject = self.viewModel.ingredients.value[sourceIndexPath.row]
            self.viewModel.ingredients.value.remove(at: sourceIndexPath.row)
            self.viewModel.ingredients.value.insert(movedObject, at: destinationIndexPath.row)
        case .step:
            let movedObject = self.viewModel.steps.value[sourceIndexPath.row]
            self.viewModel.steps.value.remove(at: sourceIndexPath.row)
            self.viewModel.steps.value.insert(movedObject, at: destinationIndexPath.row)
        case .comment:
            let movedObject = self.viewModel.comments.value[sourceIndexPath.row]
            self.viewModel.comments.value.remove(at: sourceIndexPath.row)
            self.viewModel.comments.value.insert(movedObject, at: destinationIndexPath.row)
        }
    }
}
