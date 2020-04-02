//
//  TasksListViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol TasksListViewControllerDelegate: class {
    func tasksListVCDidTapBackButton(controller: TasksListViewController)
    func tasksListVCDidTapSubmit(controller: TasksListViewController)
}

class TasksListViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var onlineAlertHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var servingsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var servingsStepper: UIStepper!
    @IBOutlet weak var servingsSeparator: UIView!
    
    weak var delegate: TasksListViewControllerDelegate?
    
    private var tasks = Event.shared.tasks.sorted { $0.taskName < $1.taskName }
//    private var sortedTasks = Event.shared.tasks.sorted { $0.taskName < $1.taskName }
    private var classifiedTasks = [[Task]]()
    private var expandableTasks = [ExpandableTasks]()
    private var sectionNames = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .tasksListVC
        
        setupUI()
        setupTableView()
        prepareTasks()
        tasksTableView.reloadData()
       
        Database.database().reference().child(Event.shared.hostIdentifier).child("Events").child(Event.shared.firebaseEventUid).child("onlineUsers").observe(.value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            self.updateOnlineAlert(value)
            
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Event.shared.addOnlineUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Event.shared.removeOnlineUser()
    }
    
    func setupUI() {
//        backButton.setTitle(" \(Event.shared.dinnerName)", for: .normal)
        setupUpdateButton()
        setupServingsView()
        
        // Should hide it at the first time opening the VC
        view.layoutIfNeeded()
        onlineAlertHeightConstraint.constant = 0
    }
    
    func setupTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(UINib(nibName: CellNibs.taskCell, bundle: nil), forCellReuseIdentifier: CellNibs.taskCell)
    }
    
    private func setupUpdateButton() {
        submitButton.layer.masksToBounds = true
        submitButton.layer.cornerRadius = 12
        submitButton.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        submitButton.alpha = 0.5
        submitButton.isEnabled = false
        if Event.shared.selectedRecipes.isEmpty && Event.shared.selectedCustomRecipes.isEmpty {
            submitButton.isHidden = true
        }
    }
    
    private func updateUpdateButton() {
        if !Event.shared.tasksNeedUpdate && !Event.shared.servingsNeedUpdate {
            submitButton.isEnabled = false
            submitButton.alpha = 0.5
        } else {
            submitButton.isEnabled = true
            submitButton.alpha = 1.0
        }
    }
    
    private func updateSummaryText() {
        let summaryForServings = "\(defaults.username) updated the servings!"
//        let summaryForTasks = "\(defaults.username) updated \(Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()) tasks for \(Event.shared.dinnerName)."
        let summaryForTasks = "\(defaults.username) updated \(Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()) tasks."
//        let summaryForTasksAndServings = "\(defaults.username) updated \(Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()) tasks for \(Event.shared.dinnerName) and the servings!"
        let summaryForTasksAndServings = "\(defaults.username) updated \(Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()) tasks and the servings!"
        let tasksUpdate = Event.shared.tasksNeedUpdate
        let servingsUpdate = Event.shared.servingsNeedUpdate
        if tasksUpdate && servingsUpdate {
            Event.shared.summary = summaryForTasksAndServings
        } else if tasksUpdate && !servingsUpdate {
            Event.shared.summary = summaryForTasks
        } else if !tasksUpdate && servingsUpdate {
            Event.shared.summary = summaryForServings
        }
    }
    
    private func setupServingsView() {
        if Event.shared.currentUser?.identifier == Event.shared.hostIdentifier {
            servingsViewHeightConstraint.constant = 60
        } else {
            servingsViewHeightConstraint.constant = 0
            servingsLabel.isHidden = true
            servingsStepper.isHidden = true
        }
        
        if Event.shared.selectedRecipes.isEmpty && Event.shared.selectedCustomRecipes.isEmpty {
            hideServingsView()
        }
        
        if Event.shared.isCancelled {
            hideServingsView()
        }
        
        servingsLabel.text = "Update servings? \(Event.shared.servings)"
        servingsLabel.textColor = UIColor.textLabel
        
        servingsStepper.minimumValue = 2
        servingsStepper.maximumValue = 12
        servingsStepper.stepValue = 1
        servingsStepper.value = Double(Event.shared.servings)
    }
    
    private func hideServingsView() {
        servingsViewHeightConstraint.constant = 0
        servingsLabel.isHidden = true
        servingsStepper.isHidden = true
        servingsSeparator.isHidden = true
    }
    
    func updateOnlineAlert(_ value: Int) {
        if value < 2 {
            view.layoutIfNeeded()
            
            // Hide with animation should not appear at the first time
            UIView.animate(withDuration: 0.2) {
                self.onlineAlertHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        } else if value > 1 {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2) {
                self.onlineAlertHeightConstraint.constant = 60
                self.view.layoutIfNeeded()
            }
            
            if !Event.shared.isSyncAlertShownInTaskListVC {
                self.showSynchronisationAlert()
                Event.shared.isSyncAlertShownInTaskListVC = true
            }
        }
    }
    
    private func prepareTasks() {
//        tasks = Event.shared.tasks
        classifiedTasks.removeAll()
        expandableTasks.removeAll()
        sectionNames.removeAll()
        
        tasks.forEach { task in
            if classifiedTasks.contains(where: { subTasks -> Bool in
                subTasks.contains { (individualTask) -> Bool in
                    individualTask.parentRecipe == task.parentRecipe
                }
            }) {
                let index = classifiedTasks.firstIndex { (subTasks) -> Bool in
                    subTasks.contains { (individualTask) -> Bool in
                        individualTask.parentRecipe == task.parentRecipe
                    }
                }
                classifiedTasks[index!].append(task)
            } else {
                classifiedTasks.append([task])
            }
        }
        classifiedTasks.forEach { subtasks in
            let subExpandableTasks = ExpandableTasks(isExpanded: true, tasks: subtasks)
            expandableTasks.append(subExpandableTasks)
            if let sectionName = subtasks.first?.parentRecipe {
                sectionNames.append(sectionName)
            }
        }
    }


    @IBAction func didTapBack(_ sender: UIButton) {
        Event.shared.servings = Event.shared.currentConversationServings
        Event.shared.servingsNeedUpdate = false
        updateSummaryText()
        
        let difference = Event.shared.tasks.difference(from: Event.shared.currentConversationTaskStates)
        
        if !difference.isEmpty {
            displayUnsavedAlert()
        } else {
            self.delegate?.tasksListVCDidTapBackButton(controller: self)
        }
    }
    
    private func displayUnsavedAlert() {
        let alert = UIAlertController(title: MessagesToDisplay.unsubmittedTasks, message: MessagesToDisplay.submitQuestion, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Nope", style: .destructive, handler: { action in
            var newTasks = [Task]()
            Event.shared.currentConversationTaskStates.forEach { task in
                let newTask = Task(taskName: task.taskName, assignedPersonUid: task.assignedPersonUid, taskState: task.taskState.rawValue, taskUid: task.taskUid, assignedPersonName: task.assignedPersonName, isCustom: task.isCustom, parentRecipe: task.parentRecipe)
                if let amount = task.metricAmount, let unit = task.metricUnit {
                    newTask.metricAmount = amount
                    newTask.metricUnit = unit
                }
                newTasks.append(newTask)
            }
            Event.shared.tasks = newTasks
            self.prepareTasks()
            self.delegate?.tasksListVCDidTapBackButton(controller: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { action in
            self.didTapSubmit(self.submitButton)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapSubmit(_ sender: UIButton) {
        Event.shared.tasksNeedUpdate = true
        delegate?.tasksListVCDidTapSubmit(controller: self)
    }
    
    
    @IBAction func didTapSortButton(_ sender: UIButton) {
        tasks = tasks.sorted(by: { $0.taskState.rawValue < $1.taskState.rawValue } )
        prepareTasks()
        tasksTableView.reloadData()
    }
    
    @IBAction func didTapStepper(_ sender: UIStepper) {
        updateServings(servings: Int(sender.value))
    }
    
    private func updateServings(servings: Int) {
        let oldServings = Event.shared.servings
        Event.shared.servings = servings
        servingsLabel.text = "Update servings? \(servings)"
        Event.shared.tasks.forEach { task in
            if !task.isCustom {
                if let amount = task.metricAmount {
                    task.metricAmount = (amount * Double(servings)) / Double(oldServings)
                    task.servings = servings
                }
            }
        }
        prepareTasks()
        tasksTableView.reloadData()
        
        if Event.shared.servings != Event.shared.currentConversationServings {
            servingsLabel.textColor = Colors.highlightRed
            Event.shared.servingsNeedUpdate = true
        } else {
            servingsLabel.textColor = .systemGray
            Event.shared.servingsNeedUpdate = false
        }
        updateUpdateButton()
        updateSummaryText()
    }
    
    private func showSynchronisationAlert() {
        let alert = UIAlertController(title: MessagesToDisplay.synchTitle,
                                      message: MessagesToDisplay.synchMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Good to know!",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
}

// MARK: TableView

extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Event.shared.tasks.count == 0 {
            tableView.setEmptyViewForRecipeView(title: LabelStrings.nothingToDo, message: "")
        } else {
            tableView.restore()
        }
        if !expandableTasks[section].isExpanded {
            return 0
        }
        return expandableTasks[section].tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskCell, for: indexPath) as! TaskCell
        let task = expandableTasks[indexPath.section].tasks[indexPath.row]
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
        return expandableTasks.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = ExpandableTaskHeaderView(expandableTasks: expandableTasks, section: section, sectionNames: sectionNames)
        headerView.tag = section
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCloseCollapse)))
        
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
        for row in expandableTasks[section].tasks.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }

        let isExpanded = expandableTasks[section].isExpanded
        expandableTasks[section].isExpanded = !isExpanded

        if isExpanded {
            tasksTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tasksTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
}

extension TasksListViewController: TaskCellDelegate {
    func taskCellUpdateProgress(indexPath: IndexPath) {
        let indexSet = NSMutableIndexSet()
        indexSet.add(indexPath.section)
        UIView.performWithoutAnimation {
            self.tasksTableView.reloadSections(indexSet as IndexSet, with: .none)
        }
    }
    
    func taskCellDidTapTaskStatusButton() {
        let difference = Event.shared.tasks.difference(from: Event.shared.currentConversationTaskStates)
        if !difference.isEmpty {
            Event.shared.tasksNeedUpdate = true
        } else {
            Event.shared.tasksNeedUpdate = false
        }
        updateUpdateButton()
        updateSummaryText()
    }
    
}
