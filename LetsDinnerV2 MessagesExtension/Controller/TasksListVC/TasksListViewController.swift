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
        prepareData()
        tasksTableView.reloadData()
        Database.database().reference().child("Events").child(Event.shared.firebaseEventUid).child("onlineUsers").observe(.value) { snapshot in
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
    }
    
    func setupTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(UINib(nibName: CellNibs.taskCell, bundle: nil), forCellReuseIdentifier: CellNibs.taskCell)
    }
    
    private func setupUpdateButton() {
        submitButton.layer.masksToBounds = true
        submitButton.alpha = 0.5
        submitButton.layer.cornerRadius = 12
        submitButton.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        submitButton.isEnabled = false
        if Event.shared.selectedRecipes.isEmpty && Event.shared.selectedCustomRecipes.isEmpty {
            submitButton.isHidden = true
        }
    }
    
    private func updateUpdateButton() {
        if !Event.shared.isTaskUpdated && !Event.shared.servingsNeedUpdate {
            submitButton.isEnabled = false
            submitButton.alpha = 0.5
        } else {
            submitButton.isEnabled = true
            submitButton.alpha = 1.0
        }
    }
    
    private func updateSummaryText() {
        let summaryForServings = "\(defaults.username) updated the servings!"
        let summaryForTasks = "\(defaults.username) updated \(Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()) tasks for \(Event.shared.dinnerName)."
        let summaryForTasksAndServings = "\(defaults.username) updated \(Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()) tasks for \(Event.shared.dinnerName) and the servings!"
        let tasksUpdate = Event.shared.isTaskUpdated
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
            servingsViewHeightConstraint.constant = 45
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
        servingsLabel.textColor = UIColor.secondaryTextLabel
        
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
            UIView.animate(withDuration: 0.2) {
                self.onlineAlertHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        } else if value > 1 {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2) {
                self.onlineAlertHeightConstraint.constant = 40
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func prepareData() {
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
            let alert = UIAlertController(title: MessagesToDisplay.unsubmittedTasks, message: MessagesToDisplay.submitQuestion, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: MessagesToDisplay.yes, style: .default, handler: { action in
                self.didTapSubmit(self.submitButton)
            }))
            alert.addAction(UIAlertAction(title: MessagesToDisplay.no, style: .destructive, handler: { action in
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
                self.prepareData()
                self.delegate?.tasksListVCDidTapBackButton(controller: self)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            self.delegate?.tasksListVCDidTapBackButton(controller: self)
        }
    }
    
    @IBAction func didTapSubmit(_ sender: UIButton) {
        Event.shared.isTaskUpdated = true
        delegate?.tasksListVCDidTapSubmit(controller: self)
    }
    
    
    @IBAction func didTapSortButton(_ sender: UIButton) {
        tasks = tasks.sorted(by: { $0.taskState.rawValue < $1.taskState.rawValue } )
        prepareData()
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
        prepareData()
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
}

extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Event.shared.tasks.count == 0 {
            tableView.setEmptyView(title: LabelStrings.nothingToDo, message: "")
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
            tableView.setEmptyView(title: LabelStrings.nothingToDo, message: "")
        } else {
            tableView.restore()
        }
        return expandableTasks.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .backgroundColor
        headerView.tag = section
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCloseCollapse)))
        
        let collapseImage : UIImageView = {
            let image = UIImageView()
            image.image = UIImage(named: "collapse")
            image.contentMode = .scaleAspectFit
            if !expandableTasks[section].isExpanded {
                image.transform = CGAffineTransform(rotationAngle: -CGFloat((Double.pi/2)))
            }
            image.restorationIdentifier = "collapse"
            return image
        }()
        
        let nameLabel : UILabel = {
            let label = UILabel()
            label.text = sectionNames[section]
            return label
        }()
        
        let separator : UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.cellSeparatorLine
            return view
        }()
        
        let progressLabel : UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            label.textColor = .systemGray
            return label
        }()
        
        let progressCircle = ProgressCircle(frame: CGRect(origin: .zero, size: CGSize(width: 25, height: 25)))
        
        headerView.addSubview(collapseImage)
        headerView.addSubview(progressCircle)
        headerView.addSubview(nameLabel)
        headerView.addSubview(progressLabel)
        headerView.addSubview(separator)
        
        collapseImage.translatesAutoresizingMaskIntoConstraints = false
        collapseImage.widthAnchor.constraint(equalToConstant: 15).isActive = true
        collapseImage.heightAnchor.constraint(equalToConstant: 15).isActive = true
        collapseImage.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10).isActive = true
        collapseImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0).isActive = true
        
        progressCircle.translatesAutoresizingMaskIntoConstraints = false
        progressCircle.widthAnchor.constraint(equalToConstant: 25).isActive = true
        progressCircle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        progressCircle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        progressCircle.trailingAnchor.constraint(equalTo: collapseImage.leadingAnchor, constant: -5).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: progressCircle.leadingAnchor, constant: 0).isActive = true
        nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        progressLabel.trailingAnchor.constraint(equalTo: progressCircle.leadingAnchor, constant: 0).isActive = true
        progressLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        progressLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5).isActive = true
        
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
        separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
        separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        
        var numberOfCompletedTasks = 0
        expandableTasks[section].tasks.forEach { task in
            if task.taskState == .completed {
                numberOfCompletedTasks += 1
            }
        }
        let percentage : Double = Double(numberOfCompletedTasks)/Double(expandableTasks[section].tasks.count)
        progressCircle.animate(percentage: percentage)
        
        var numberOfUnassignedTasks = 0
        expandableTasks[section].tasks.forEach { task in
            if task.taskState == .unassigned {
                numberOfUnassignedTasks += 1
            }
        }
        
        if numberOfUnassignedTasks == 0 {
            progressLabel.text = "All items assigned"
        } else if numberOfUnassignedTasks == 1 {
            progressLabel.text = "\(numberOfUnassignedTasks) item unassigned"
        } else {
            progressLabel.text = "\(numberOfUnassignedTasks) items unassigned"
        }
        
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
            Event.shared.isTaskUpdated = true
        } else {
            Event.shared.isTaskUpdated = false
        }
        updateUpdateButton()
        updateSummaryText()
    }
    
}
