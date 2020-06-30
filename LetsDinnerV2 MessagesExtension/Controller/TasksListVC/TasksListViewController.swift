//
//  TasksListViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 19/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift

protocol TasksListViewControllerDelegate: class {
    func tasksListVCDidTapBackButton()
    func tasksListVCDidTapSubmit()
}

class TasksListViewController: LDNavigationViewController {
    // MARK: Properties
    private let submitButton : PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(LabelStrings.update, for: .normal)
        button.isHidden = Event.shared.tasks.isEmpty
        return button
    }()
    
    private let navigationSeparator : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    private let alertBanner = LDAlertBanner(LabelStrings.multipleUsers)
    
    private let updateBanner = LDUpdateBanner()
    
    private let servingsView = LDServingsView()
    
    private let loadingView = LDLoadingView()
    
    private let tasksTableView : UITableView = {
        let tv = UITableView()
        tv.showsVerticalScrollIndicator = false
        tv.backgroundColor = .backgroundColor
        tv.separatorStyle = .none
        tv.tableFooterView = UIView()
        return tv
    }()
    
    weak var delegate: TasksListViewControllerDelegate?
    
    private let viewModel: TasksListViewModel
    
    // MARK: Init
    init(viewModel: TasksListViewModel, delegate: TasksListViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StepStatus.currentStep = .tasksListVC
        viewModel.addOnlineUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removeOnlineUser()
    }
    
    // MARK: ViewModel Binding
    private func bindViewModel() {
        
        viewModel.servings <~ servingsView.stepper.reactive.values.map { Int($0) }
        
        navigationBar.previousButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            Event.shared.servings = Event.shared.currentConversationServings
            self.viewModel.updateSummaryText()
            if Event.shared.tasksNeedUpdate {
                self.displayPendingChangesAlert()
            } else {
                self.delegate?.tasksListVCDidTapBackButton()
            }
        }
        
        navigationBar.nextButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.viewModel.sortTasks()
        }
        
        submitButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.delegate?.tasksListVCDidTapSubmit()
        }
        
        updateBanner.updateButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.updateBanner.disappear()
            self.viewModel.updateTasks()
        }
        
        self.viewModel.newDataSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeResult { [weak self] _ in
                guard let self = self else { return }
                self.tasksTableView.reloadData()
                self.updateSubmitButton()
        }
        
        self.viewModel.onlineUsersSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [weak self] value in
                guard let self = self else { return }
                value > 1 ? self.alertBanner.appear() : self.alertBanner.disappear()
                if value > 1 && !Event.shared.shouldShowSyncAlert {
                    self.showSyncAlert()
                    Event.shared.shouldShowSyncAlert = true
                }
        }
        
        self.viewModel.taskUpdateSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [weak self] _ in
                guard let self = self else { return }
                self.updateBanner.appear()
        }
        
        self.viewModel.isLoading.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.view.addSubview(self.loadingView)
                    self.loadingView.snp.makeConstraints { make in
                        make.leading.trailing.bottom.equalToSuperview()
                        make.top.equalTo(self.updateBanner.snp.bottom)
                    }
                    self.loadingView.start()
                } else {
                    self.loadingView.stop()
                }
        }
        
        viewModel.servings.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] servings in
                guard let self = self else { return }
                self.servingsView.label.text = String.localizedStringWithFormat(LabelStrings.updateServings, servings)
                self.servingsView.stepper.value = Double(servings)
                self.servingsView.label.textColor = Event.shared.servingsNeedUpdate ? .activeButton : .textLabel
                self.updateSubmitButton()
        }
    }
    
    // MARK: Methods
    private func setupTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.registerCells(CellNibs.taskCell)
    }
    
    private func displayPendingChangesAlert() {
        let alert = UIAlertController(title: AlertStrings.unsubmittedTasks,
                                      message: AlertStrings.submitQuestion,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AlertStrings.nope,
                                      style: .destructive,
                                      handler: { _ in
                                        self.viewModel.restoreTasks()
                                        self.delegate?.tasksListVCDidTapBackButton()
        }))
        alert.addAction(UIAlertAction(title: AlertStrings.update,
                                      style: .default,
                                      handler: { _ in
                                        self.delegate?.tasksListVCDidTapSubmit()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func showSyncAlert() {
        let alert = UIAlertController(title: AlertStrings.syncTitle,
                                      message: AlertStrings.syncMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AlertStrings.goodToKnow,
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func updateSubmitButton() {
        submitButton.isEnabled = Event.shared.tasksNeedUpdate || Event.shared.servingsNeedUpdate
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        progressViewContainer.isHidden = true
        navigationBar.nextButton.setImage(Images.sortIcon, for: .normal)
        navigationBar.nextButton.setTitle("", for: .normal)
        navigationBar.titleLabel.text = LabelStrings.manageThings
        navigationBar.previousButton.setTitle(LabelStrings.back, for: .normal)
        navigationBar.previousButton.setImage(Images.chevronLeft, for: .normal)
        view.addSubview(submitButton)
        view.addSubview(navigationSeparator)
        view.addSubview(alertBanner)
        view.addSubview(updateBanner)
        view.addSubview(servingsView)
        view.addSubview(tasksTableView)
        addConstraints()
    }
    
    private func addConstraints() {
        submitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        navigationSeparator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(navigationBar.snp.bottom)
        }
        
        alertBanner.snp.makeConstraints { make in
            make.top.equalTo(navigationSeparator.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        updateBanner.snp.makeConstraints { make in
            make.top.equalTo(alertBanner.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        var servingsViewHeight = 0
        
        if Event.shared.currentUser?.identifier == Event.shared.hostIdentifier {
            servingsViewHeight = 60
        } else {
            servingsViewHeight = 0
            servingsView.hide()
        }
        
        if Event.shared.selectedRecipes.isEmpty && Event.shared.selectedCustomRecipes.isEmpty ||
            Event.shared.isCancelled {
            servingsViewHeight = 0
            servingsView.hide()
        }
        
        servingsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(updateBanner.snp.bottom)
            make.height.equalTo(servingsViewHeight)
        }
        
        tasksTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(servingsView.snp.bottom)
            make.bottom.equalTo(submitButton.snp.top).offset(-10)
        }
    }
}

// MARK: TableView Delegate
extension TasksListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Event.shared.tasks.count == 0 {
            tableView.setEmptyViewForRecipeView(title: LabelStrings.nothingToDo, message: "")
        } else {
            tableView.restore()
        }
        if !viewModel.expandableTasks[section].isExpanded {
            return 0
        }
        return viewModel.expandableTasks[section].tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskCell, for: indexPath) as! TaskCell
        let task = viewModel.expandableTasks[indexPath.section].tasks[indexPath.row]
        taskCell.configureCell(task: task, indexPath: indexPath.row)
        taskCell.delegate = self
        return taskCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskCell = tableView.cellForRow(at: indexPath) as! TaskCell
        taskCell.didTapTaskStatusButton(indexPath: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if Event.shared.tasks.count == 0 {
            tableView.setEmptyViewForRecipeView(title: LabelStrings.nothingToDo, message: "")
        } else {
            tableView.restore()
        }
        return viewModel.expandableTasks.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = ExpandableTaskHeaderView(expandableTasks: viewModel.expandableTasks,
                                                  section: section,
                                                  sectionNames: viewModel.sectionNames.value)
        headerView.tag = section
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(handleCloseCollapse)))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    @objc func handleCloseCollapse(sender: UITapGestureRecognizer) {
        let section = sender.view!.tag
        sender.view?.subviews.forEach({ subview in
            if subview.restorationIdentifier == "collapse" {
                subview.rotate()
            }
        })
        var indexPaths = [IndexPath]()
        for row in viewModel.expandableTasks[section].tasks.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = viewModel.expandableTasks[section].isExpanded
        viewModel.expandableTasks[section].isExpanded = !isExpanded
        
        if isExpanded {
            tasksTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tasksTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
}

// MARK: TaskCell Delegate
extension TasksListViewController: TaskCellDelegate {
    func taskCellUpdateProgress(indexPath: IndexPath) {
        let indexSet = NSMutableIndexSet()
        indexSet.add(indexPath.section)
        UIView.performWithoutAnimation {
            self.tasksTableView.reloadSections(indexSet as IndexSet, with: .none)
        }
    }
    
    func taskCellDidTapTaskStatusButton() {
        self.updateSubmitButton()
        viewModel.updateSummaryText()
    }
}
