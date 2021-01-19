//
//  ManagementViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 12/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift
import FirebaseAnalytics

protocol ManagementViewControllerDelegate: class {
    func managementVCDidTapBack()
    func managementVCDdidTapNext()
}

class ManagementViewController: LDNavigationViewController {
    
    weak var delegate: ManagementViewControllerDelegate?

    // MARK: Properties
    private let tasksTableView : UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.rowHeight = 120
        tv.showsVerticalScrollIndicator = false
        tv.backgroundColor = .backgroundColor
        return tv
    }()
    
    private let addButton : UIButton = {
        let button = UIButton()
        button.setTitle(LabelStrings.addThing, for: .normal)
        button.setImage(Images.addButtonOutlined, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitleColor(.activeButton, for: .normal)
        return button
    }()
    
    private let servingsView = UIView()
    
    private let servingsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.textLabel
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let servingsStepper : UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 2
        stepper.maximumValue = 12
        stepper.stepValue = 1
        return stepper
    }()
    
    private let separator : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.sectionSeparatorLine
        return view
    }()
    
    private let bottomView : UIView = {
        let view = UIView()
        view.alpha = 0.9
        view.backgroundColor = UIColor.bottomViewColor
        return view
    }()
    
    private lazy var footerView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tasksTableView.frame.width, height: 60))
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var deleteTaskLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 5, width: self.view.frame.width , height: 15))
        label.text = LabelStrings.deleteTaskLabel
        label.textColor = UIColor.secondaryTextLabel
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var assignTaskLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tasksTableView.frame.width , height: 15))
        label.text = LabelStrings.assignTaskLabel
        label.textColor = UIColor.secondaryTextLabel
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var headerView: ExpandableTaskHeaderView?
    private var addThingView: AddNewThingView?
    
    private var tapGestureToHideKeyboard = UITapGestureRecognizer()
    private var swipeDownGestureToHideKeyBoard = UISwipeGestureRecognizer()
    
    #warning("Solve problem with section selection input")
    private var selectedSection : String?

    private let viewModel: ManagementViewModel
    
    private let bottomViewHeight: CGFloat = UIDevice.current.type == .iPad ? 90 : (UIDevice.current.hasHomeButton ? 60 : 75)
    private let addThingViewHeight: CGFloat = 94
    
    //MARK: Init
    init(viewModel: ManagementViewModel, delegate: ManagementViewControllerDelegate) {
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
        configureTableView()
        bindViewModel()
        addKeyboardNotifications()
        configureAddThingView()
        configureGestures()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StepStatus.currentStep = .managementVC
    }
    
    // MARK: ViewModel Binding
    private func bindViewModel() {
      
        viewModel.servings <~ servingsStepper.reactive.values.map { Int($0) }
        
        navigationBar.previousButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.view.endEditing(true)
            self.delegate?.managementVCDidTapBack()
        }
        
        navigationBar.nextButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.view.endEditing(true)
            self.delegate?.managementVCDdidTapNext()
        }
        
        addButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.addThingView!.mainTextField.becomeFirstResponder()
            NotificationCenter.default.post(name: Notification.Name("KeyboardWillShow"), object: nil)
        }
        
        viewModel.tasks.producer
        .observe(on: UIScheduler())
        .take(duringLifetimeOf: self)
        .startWithValues { [weak self] tasks in
            guard let self = self else { return }
            self.servingsView.isHidden = tasks.isEmpty
            self.footerView.isHidden = tasks.isEmpty
        }
        
        viewModel.servings.producer
        .observe(on: UIScheduler())
        .take(duringLifetimeOf: self)
        .startWithValues { [weak self] servings in
            guard let self = self else { return }
            self.servingsLabel.text = String.localizedStringWithFormat(LabelStrings.servingDisplayLabel, String(servings))
            self.servingsStepper.value = Double(servings)
            Event.shared.servings = servings
        }
        
        viewModel.sectionNames.producer
        .observe(on: UIScheduler())
        .take(duringLifetimeOf: self)
        .startWithValues { [weak self] sectionNames in
            guard let self = self else { return }
            self.addThingView?.sectionNames = sectionNames
        }
        
        self.viewModel.newDataSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeResult { [weak self] _ in
                guard let self = self else { return }
                self.tasksTableView.reloadData()
        }
    }
    
    // MARK: Methods
    private func configureTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(TaskManagementCell.self,
                                forCellReuseIdentifier: TaskManagementCell.reuseID)
        
        tasksTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.bottomViewHeight, right: 0)

        footerView.addSubview(deleteTaskLabel)
        footerView.addSubview(assignTaskLabel)
        tasksTableView.tableFooterView = footerView
    }
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: Notification.Name("KeyboardWillShow"),
                                               object: nil)
    }
    
    private func configureAddThingView() {
        addThingView = AddNewThingView(type: .manageTask,
                                       sectionNames: viewModel.sectionNames.value,
                                       selectedSection: selectedSection)
        addThingView?.addThingDelegate = self
    }
    
    
    private func configureGestures() {
        // Should only tap on the view not on the keyboard
        tapGestureToHideKeyboard = UITapGestureRecognizer(target: self.view,
                                                          action: #selector(UIView.endEditing(_:)))
        tapGestureToHideKeyboard.delegate = self
        
        swipeDownGestureToHideKeyBoard = UISwipeGestureRecognizer(target: addThingView,
                                                                  action: #selector(UIView.endEditing(_:)))
        swipeDownGestureToHideKeyBoard.direction = .down

//        self.view.addSwipeGestureRecognizer(action: { self.delegate?.managementVCDidTapBack() })
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(servingsView)
        view.addSubview(tasksTableView)
        view.addSubview(bottomView)
        view.addSubview(addThingView!)
        
        navigationBar.titleLabel.text = LabelStrings.manageThings
        navigationBar.previousButton.setImage(Images.chevronLeft, for: .normal)
        navigationBar.previousButton.setTitle(LabelStrings.recipes, for: .normal)
        servingsView.addSubview(servingsLabel)
        servingsView.addSubview(servingsStepper)
        servingsView.addSubview(separator)

        bottomView.addSubview(addButton)
        addConstraints()
    }
    
    private func addConstraints() {
        servingsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom)
            make.height.equalTo(60)
        }
        
        servingsLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(18)
        }
        
        servingsStepper.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        separator.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(1)
        }
        
        tasksTableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(servingsView.snp.bottom)
        }
        
        bottomView.snp.makeConstraints { make in
            make.height.equalTo(bottomViewHeight)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(15)
        }
        
        deleteTaskLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(15)
        }
        
        assignTaskLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(deleteTaskLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
        }
        
        addThingView?.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(94)
            make.height.equalTo(94)
        }
    }
}
    // MARK: TableViewDelegate
extension ManagementViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Event.shared.tasks.isEmpty {
            tableView.setEmptyViewForManagementVC(title: LabelStrings.noTaskTitle,
                                                  message: LabelStrings.noTaskMessage,
                                                  message2: LabelStrings.noTaskMessage2)
        } else {
            tableView.restore()
        }
        
        if !viewModel.expandableTasks[section].isExpanded {
            return 0
        }
        return viewModel.expandableTasks[section].tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskManagementCell = tableView.dequeueReusableCell(withIdentifier: TaskManagementCell.reuseID, for: indexPath) as! TaskManagementCell
        let task = viewModel.expandableTasks[indexPath.section].tasks[indexPath.row]
        taskManagementCell.configureCell(task: task)
        taskManagementCell.delegate = self
        return taskManagementCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskManagementCell = tableView.cellForRow(at: indexPath) as! TaskManagementCell
        taskManagementCell.didTapTaskStatusButton(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if Event.shared.tasks.isEmpty {
            tableView.setEmptyViewForManagementVC(title: LabelStrings.noTaskTitle,
                                                  message: LabelStrings.noTaskMessage,
                                                  message2: LabelStrings.noTaskMessage2)
        } else {
            tableView.restore()
        }
        
        return viewModel.expandableTasks.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView = ExpandableTaskHeaderView(expandableTasks: self.viewModel.expandableTasks, section: section, sectionNames: self.viewModel.sectionNames.value)
        guard let headerView = headerView else { return nil }
        headerView.tag = section
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCloseCollapse))
        headerView.addGestureRecognizer(tapGesture)
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
    
    // MARK: Swipe Right Action
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskManagementCell = tableView.cellForRow(at: indexPath) as! TaskManagementCell
        
        let assignToMyselfAction = UIContextualAction(style: .normal,
                                                      title: title,
                                                      handler: { (action, view, completionHandler) in
                                                        taskManagementCell.didSwipeTaskStatusButton(indexPath: indexPath,
                                                                                                    changeTo: .assigned)
                                                        completionHandler(true)
        })
        
        let completedAction = UIContextualAction(style: .normal,
                                                 title: title,
                                                 handler: { (action, view, completionHandler) in
                                                    taskManagementCell.didSwipeTaskStatusButton(indexPath: indexPath,
                                                                                                changeTo: .completed)
                                                    completionHandler(true)
        })
        
        assignToMyselfAction.backgroundColor = .swipeRightButton
        assignToMyselfAction.image = Images.swipeActionAssign
        completedAction.backgroundColor = .activeButton
        completedAction.image = Images.swipeActionComplete
        
        let configuration = UISwipeActionsConfiguration(actions: [assignToMyselfAction, completedAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    // MARK: Delete Task
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: { _, _, complete in
            
            self.deleteTask(indexPath: indexPath)
            
            complete(true)
            
            // Refresh Data after completion, for smoother animation
            self.viewModel.prepareData()
        })
        
        deleteAction.image = UIImage(named: "deleteIcon.png")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            self.deleteTask(indexPath: indexPath)
        }
    }
    
    private func deleteTask(indexPath: IndexPath) {
        let taskToDelete = viewModel.expandableTasks[indexPath.section].tasks[indexPath.row]
        let index = Event.shared.tasks.firstIndex { taskToDelete.id == $0.id }
        Event.shared.tasks.remove(at: index!)
        viewModel.tasks.value = Event.shared.tasks
        
        viewModel.expandableTasks[indexPath.section].tasks.remove(at: indexPath.row)
        if viewModel.expandableTasks[indexPath.section].tasks.count == 0 {
            viewModel.expandableTasks.remove(at: indexPath.section)
            viewModel.sectionNames.value.remove(at: indexPath.section)
        }
        
        if tasksTableView.numberOfRows(inSection: indexPath.section) > 1 {
            tasksTableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
            // This is in case we want to remove the recipe from the selected recipes if all tasks are deleted
//            let recipeName = taskToDelete.parentRecipe
//            let index = Event.shared.selectedRecipes.firstIndex { $0.title == recipeName }
//            if let index = index {
//                Event.shared.selectedRecipes.remove(at: index)
//            }
//            let customIndex = Event.shared.selectedCustomRecipes.firstIndex { $0.title == recipeName }
//            if let index = customIndex {
//                Event.shared.selectedCustomRecipes.remove(at: index)
//            }
//            let publicIndex = Event.shared.selectedPublicRecipes.firstIndex { $0.title == recipeName }
//            if let index = publicIndex {
//                Event.shared.selectedPublicRecipes.remove(at: index)
//            }
            let indexSet = NSMutableIndexSet()
            indexSet.add(indexPath.section)
            tasksTableView.deleteSections(indexSet as IndexSet, with: .automatic)
        }
    }
}

extension ManagementViewController: TaskManagementCellDelegate {
    func taskManagementCellDidTapTaskStatusButton(indexPath: IndexPath) {
        // No need for prepareData apparently
        // prepareData()
        let indexSet = NSMutableIndexSet()
        indexSet.add(indexPath.section)
        // Amazing trick to avoid weird behavior when sections are reloaded:
        UIView.performWithoutAnimation {
            self.tasksTableView.reloadSections(indexSet as IndexSet, with: .none)
        }
    }
}

extension ManagementViewController: AddThingDelegate {
    func doneEditThing(selectedSection: String?, item: String?, amount: String?, unit: String?) {
        Analytics.logEvent("add_custom_task", parameters: nil)
        viewModel.prepareData()
    }

    private func showAddThingView(offset: CGFloat) {
        guard let addThingView = addThingView else { return }
        var offset = offset
        #warning("Temporary solve for iPad ios13")
        if UIDevice.current.userInterfaceIdiom == .pad {
            if #available(iOS 13.0, *) {
                offset += 20
            }
        }
        addThingView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(addThingViewHeight)
            make.bottom.equalToSuperview().offset(-offset)
        }
    }
    
    private func removeAddThingView() {
        guard let addThingView = addThingView else { return }
        addThingView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(94)
            make.bottom.equalToSuperview().offset(94)
        }
    }
}

extension ManagementViewController {
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        UIView.animate(withDuration: 1) {
            self.showAddThingView(offset: keyboardFrame.height)
        }
        
        self.tasksTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + addThingViewHeight, right: 0)
        self.view.layoutIfNeeded()

        self.view.addGestureRecognizer(tapGestureToHideKeyboard)
        self.view.addGestureRecognizer(swipeDownGestureToHideKeyBoard)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 1) {
            self.removeAddThingView()
        }
        self.tasksTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomViewHeight, right: 0)
        self.view.layoutIfNeeded()
        
        self.view.removeGestureRecognizer(tapGestureToHideKeyboard)
        self.view.removeGestureRecognizer(swipeDownGestureToHideKeyBoard)
    }
}

extension ManagementViewController: UIGestureRecognizerDelegate {
    // To prevent touch in "Add Thing" View
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchView = touch.view else { return true }
        if let addThingView = addThingView {
            return !touchView.isDescendant(of: addThingView)
        } else {
            return true
        }
    }
}
