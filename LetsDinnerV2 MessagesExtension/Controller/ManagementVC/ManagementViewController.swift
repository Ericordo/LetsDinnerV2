//
//  ManagementViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 15/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol ManagementViewControllerDelegate: class {
    func managementVCDidTapBack(controller: ManagementViewController)
    func managementVCDdidTapNext(controller: ManagementViewController)
}

class ManagementViewController: UIViewController {
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var tasksTableView: UITableView!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var servingsLabel: UILabel!
    @IBOutlet private weak var servingsStepper: UIStepper!
    @IBOutlet weak var separatorView: UIView!
    
    // Add Things
    @IBOutlet weak var addThingView: UIView!
    @IBOutlet weak var addThingViewBottomConstraint: NSLayoutConstraint!
        
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: ManagementViewControllerDelegate?
    
    // MARK: Variables
    private var tasks = Event.shared.tasks {
        didSet {
            hideServingView()
            hideFooterView()
        }
    }
    private var classifiedTasks = [[Task]]()
    private var expandableTasks = [ExpandableTasks]()
    
    private var sectionNames = [String]() {
        didSet {
            newThingView!.sectionNames = self.sectionNames
        }
    }
    private var servings : Int = 2 {
        didSet {
            servingsLabel.text = "\(servings) Servings"
            Event.shared.servings = servings
        }
    }

    private var selectedSection : String?
    var tapGestureToHideKeyboard = UITapGestureRecognizer()
    var swipeDownGestureToHideKeyBoard = UISwipeGestureRecognizer()
    
    var newThingView: AddNewThingView?
    private var headerView: ExpandableTaskHeaderView?
    var footerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .managementVC
        
        configureUI()
        configureTableView()
        configureNewThingView()
        configureGestureRecognizers()

        // update variable and preparedata
        servings = Event.shared.servings
        self.updateServings(servings: servings)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name("keyboardWillShow"), object: nil)
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.post(name: Notification.Name("didGoToNextStep"), object: nil, userInfo: ["step": 3])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.addThingViewBottomConstraint.constant = -100
        self.view.layoutIfNeeded()
    }
    
    
    
    // MARK: Configuration
    private func configureUI() {
        servingsLabel.text = "\(servings) Servings"
        servingsLabel.textColor = UIColor.textLabel
        
        servingsStepper.minimumValue = 2
        servingsStepper.maximumValue = 12
        servingsStepper.stepValue = 1
        servingsStepper.value = Double(servings)

        separatorView.backgroundColor = UIColor.sectionSeparatorLine
        
        self.addShadowOnUIView(view: addThingView)

        if Event.shared.selectedRecipes.isEmpty && Event.shared.selectedCustomRecipes.isEmpty {
            hideServingView()
            hideFooterView()
        }
        
        if UIDevice.current.hasHomeButton {
            bottomViewHeightConstraint.constant = 60
            self.bottomView.layoutIfNeeded()
        }
        
    }
    
    private func configureNewThingView() {
        newThingView = AddNewThingView(sectionNames: sectionNames, selectedSection: selectedSection)
        newThingView?.addThingDelegate = self
    
        addThingView.addSubview(newThingView!)
        
        newThingView!.translatesAutoresizingMaskIntoConstraints = false
        newThingView!.anchor(top: addThingView.topAnchor,
                             leading: addThingView.leadingAnchor,
                             bottom: addThingView.bottomAnchor,
                             trailing: addThingView.trailingAnchor)
    }
    
    func addShadowOnUIView(view: UIView) {
        view.layer.shadowColor = Colors.separatorGrey.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func configureGestureRecognizers() {
        // Should only tap on the view not on the keyboard
        tapGestureToHideKeyboard = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapGestureToHideKeyboard.delegate = self
        
        swipeDownGestureToHideKeyBoard = UISwipeGestureRecognizer(target: newThingView, action: #selector(UIView.endEditing(_:)))
        swipeDownGestureToHideKeyBoard.direction = .down
        
        setupSwipeBackGesture()
    }
    
    private func configureTableView() {
//        tasksTableView.tableFooterView = UIView()
        tasksTableView.backgroundColor = .backgroundColor

        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(UINib(nibName: CellNibs.taskManagementCell, bundle: nil), forCellReuseIdentifier: CellNibs.taskManagementCell)
        
        // Configure Footer View
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: tasksTableView.frame.width, height: 60))
        
        guard let footerView = footerView else { return }
        footerView.backgroundColor = .clear
        
        let deleteTaskLabel: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 5, width: self.view.frame.width , height: 15)
            label.text = LabelStrings.deleteTaskLabel
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 12)
            label.textAlignment = .center
            label.backgroundColor = .clear
            return label
        }()
        
        let assignTaskLabel: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: tasksTableView.frame.width , height: 15)
            label.text = LabelStrings.assignTaskLabel
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 12)
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        footerView.addSubview(deleteTaskLabel)
        footerView.addSubview(assignTaskLabel)
        
        tasksTableView.tableFooterView = footerView
        tasksTableView.separatorStyle = .none
        tasksTableView.rowHeight = 120
        tasksTableView.showsVerticalScrollIndicator = false
        
        deleteTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        assignTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        
        deleteTaskLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        assignTaskLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true

        
        deleteTaskLabel.anchor(top: footerView.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        assignTaskLabel.anchor(top: deleteTaskLabel.bottomAnchor, leading: footerView.leadingAnchor, bottom: nil, trailing: footerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 25, bottom: 0, right: 25))
        
    }
    
    private func setupSwipeBackGesture() {
        self.view.addSwipeGestureRecognizer(action: {self.delegate?.managementVCDidTapBack(controller: self)})
    }
    
    //MARK: prepareData
    private func prepareData() {
        tasks = Event.shared.tasks
        classifiedTasks.removeAll()
        
        var expandedStatus = [String : Bool]()
        
        expandableTasks.forEach { expandableTasks in
            if let parentRecipe = expandableTasks.tasks.first?.parentRecipe {
                expandedStatus[parentRecipe] = expandableTasks.isExpanded
            }
        }

        expandableTasks.removeAll()
        sectionNames.removeAll()
        
        // Append the task into classified Task
        tasks.forEach { task in
            if classifiedTasks.contains(where: { subTasks -> Bool in
                subTasks.contains { (individualTask) -> Bool in
                    individualTask.parentRecipe == task.parentRecipe}
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
        
        // Append Expandable Tasks
        classifiedTasks.forEach { subtasks in
            var subExpandableTasks = ExpandableTasks(isExpanded: true, tasks: subtasks)
            if let parentRecipe = subtasks.first?.parentRecipe {
                if let isExpanded = expandedStatus[parentRecipe] {
                    subExpandableTasks = ExpandableTasks(isExpanded: isExpanded, tasks: subtasks)
                }
            }
            
//            let subExpandableTasks = ExpandableTasks(isExpanded: true, tasks: subtasks)
            
            expandableTasks.append(subExpandableTasks)
            if let sectionName = subtasks.first?.parentRecipe {
                sectionNames.append(sectionName)
            }
        }
        
        expandedStatus.removeAll()
    }
    
    // MARK: Button Tapped
    
    
    @IBAction func didTapStepper(_ sender: UIStepper) {
        updateServings(servings: Int(sender.value))
    }
    
    @IBAction private func didTapBack(_ sender: UIButton) {
        delegate?.managementVCDidTapBack(controller: self)
    }
    
    @IBAction private func didTapNext(_ sender: UIButton) {
        delegate?.managementVCDdidTapNext(controller: self)
    }
    
    @IBAction private func didTapAdd(_ sender: UIButton) {
        self.selectedSection = "Miscellaneous"
        
        newThingView?.newThingTitleTextField.becomeFirstResponder()
        NotificationCenter.default.post(name: Notification.Name("keyboardWillShow"), object: nil)

//

//        var textField = UITextField()
//        let alert = UIAlertController(title: MessagesToDisplay.addThing, message: "", preferredStyle: .alert)
//        let add = UIAlertAction(title: MessagesToDisplay.add, style: .default) { action in
//            if !textField.text!.isEmpty {
//            let newTask = Task(taskName: textField.text!,
//                               assignedPersonUid: "nil",
//                               taskState: TaskState.unassigned.rawValue,
//                               taskUid: "nil",
//                               assignedPersonName: "nil",
//                               isCustom: true,
//                               parentRecipe: self.selectedSection ?? "Miscellaneous")
//            Event.shared.tasks.append(newTask)
//            self.prepareData()
//            self.tasksTableView.reloadData()
//            }
//        }
//        let cancel = UIAlertAction(title: MessagesToDisplay.cancel, style: .cancel, handler: nil)
//        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = MessagesToDisplay.thingToAdd
//            textField = alertTextField
//            let input = SectionSelectionInput(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 44)))
//            input.configureInput(sections: self.sectionNames)
//            input.sectionSelectionInputDelegate = self
//            self.selectedSection = "Miscellaneous"
//            textField.inputAccessoryView = input
//        }
//        alert.addAction(add)
//        alert.addAction(cancel)
//        present(alert, animated: true, completion: nil)
    }

    
    // MARK: Other functions
    
    private func hideServingView() {
        if tasks.isEmpty {
            servingsLabel.isHidden = true
            servingsStepper.isHidden = true
            separatorView.isHidden = true
        } else {
            servingsLabel.isHidden = false
            servingsStepper.isHidden = false
            separatorView.isHidden = false
        }
    }
    
    private func hideFooterView() {
        guard let footerView = footerView else { return }
        if tasks.isEmpty {
            footerView.isHidden = true
        } else {
            footerView.isHidden = false
        }
    }
    
    private func updateServings(servings: Int) {
      
        self.servings = servings
        
        Event.shared.tasks.forEach { task in
            if !task.isCustom {
                if let amount = task.metricAmount, let oldServings = task.servings {
                    task.metricAmount = (amount * Double(servings)) / Double(oldServings)
                    task.servings = servings
                }
            }
        }
        
        prepareData()
        tasksTableView.reloadData()
    }
    
    
}

// MARK: TableView setup

extension ManagementViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if Event.shared.tasks.isEmpty {
            tableView.setEmptyViewForManagementVC(title: LabelStrings.noTaskTitle, message: LabelStrings.noTaskMessage, message2: LabelStrings.noTaskMessage2)
        } else {
            tableView.restore()
        }
        
        if !expandableTasks[section].isExpanded {
            return 0
        }
        return expandableTasks[section].tasks.count
      }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskManagementCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskManagementCell, for: indexPath) as! TaskManagementCell
        let task = expandableTasks[indexPath.section].tasks[indexPath.row]
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
    
// MARK: Add for task management
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // MARK: Delete Task
        if (editingStyle == .delete) {
            let taskToDelete = expandableTasks[indexPath.section].tasks[indexPath.row]
            let index = Event.shared.tasks.firstIndex { (task) -> Bool in
                taskToDelete.taskName == task.taskName && taskToDelete.parentRecipe == task.parentRecipe
            }
            
            Event.shared.tasks.remove(at: index!)
            tasks = Event.shared.tasks
            
            expandableTasks[indexPath.section].tasks.remove(at: indexPath.row)
            if expandableTasks[indexPath.section].tasks.count == 0 {
                expandableTasks.remove(at: indexPath.section)
                sectionNames.remove(at: indexPath.section)
            }
//            prepareData()
           
            if tasksTableView.numberOfRows(inSection: indexPath.section) > 1 {
                tasksTableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                let recipeName = taskToDelete.parentRecipe
                let index = Event.shared.selectedRecipes.firstIndex { recipe -> Bool in
                    recipe.title == recipeName
                }
                if let index = index {
                    Event.shared.selectedRecipes.remove(at: index)
                }
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section)
                tasksTableView.deleteSections(indexSet as IndexSet, with: .automatic)
            }
//            prepareData()
            self.doneEditThing()
        }
    }
    
    // MARK: Swipe Right Action
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskManagementCell = tableView.cellForRow(at: indexPath) as! TaskManagementCell
        
        let assignToMyselfAction = UIContextualAction(style: .normal, title: title,
        handler: { (action, view, completionHandler) in
            taskManagementCell.didSwipeTaskStatusButton(indexPath: indexPath, changeTo: .assigned)
            completionHandler(true)
        })
        
        let completedAction = UIContextualAction(style: .normal, title: title,
          handler: { (action, view, completionHandler) in
            taskManagementCell.didSwipeTaskStatusButton(indexPath: indexPath, changeTo: .completed)
            completionHandler(true)
        })


        assignToMyselfAction.image = UIImage(named: "")
        assignToMyselfAction.backgroundColor = .swipeRightButton
        
        completedAction.image = UIImage(named: "")
        completedAction.backgroundColor = .activeButton
        
        
        
        let configuration = UISwipeActionsConfiguration(actions: [assignToMyselfAction, completedAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }
    
// MARK: Add for sections and collapsable rows
    
     func numberOfSections(in tableView: UITableView) -> Int {
        
        if Event.shared.tasks.isEmpty {
            tableView.setEmptyViewForManagementVC(title: LabelStrings.noTaskTitle, message: LabelStrings.noTaskMessage, message2: LabelStrings.noTaskMessage2)
            } else {
                tableView.restore()
            }
        
        return expandableTasks.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        headerView = ExpandableTaskHeaderView(expandableTasks: expandableTasks,
                                                  section: section,
                                                  sectionNames: sectionNames)
        if let headerView = headerView {
            headerView.tag = section
            headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCloseCollapse)))
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
//    @objc func handleCloseCollapse(button: UIButton) {
//        button.rotate()
//        let section = button.tag
//        var indexPaths = [IndexPath]()
//        for row in expandableTasks[section].tasks.indices {
//            let indexPath = IndexPath(row: row, section: section)
//            indexPaths.append(indexPath)
//        }
//
//        let isExpanded = expandableTasks[section].isExpanded
//        expandableTasks[section].isExpanded = !isExpanded
//
//        if isExpanded {
//            tasksTableView.deleteRows(at: indexPaths, with: .fade)
//        } else {
//            tasksTableView.insertRows(at: indexPaths, with: .fade)
//        }
//    }
    
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

extension ManagementViewController: TaskManagementCellDelegate {
    func taskManagementCellDidTapTaskStatusButton(indexPath: IndexPath) {
        // No need for prepareData apparently
        //        prepareData()
        let indexSet = NSMutableIndexSet()
        indexSet.add(indexPath.section)
        //        Amazing trick to avoid weird behavior when sections are reloaded:
        UIView.performWithoutAnimation {
            self.tasksTableView.reloadSections(indexSet as IndexSet, with: .none)
        }
    }
}

// MARK: AddThing Delegation

extension ManagementViewController: AddThingDelegate {
    func doneEditThing() {
        self.prepareData()
        self.tasksTableView.reloadData()
    }
}

extension ManagementViewController: UIGestureRecognizerDelegate {
    
    // To prevent touch in "Add Thing" View
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: addThingView) {
            return false
        }
        return true
    }
}

// MARK: Keyboard

extension ManagementViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1) {
            self.addThingViewBottomConstraint.constant = keyboardFrame.height
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.addThingViewBottomConstraint.constant += 20
            }
            
            self.view.layoutIfNeeded()
        }
        
        self.view.addGestureRecognizer(tapGestureToHideKeyboard)
        self.view.addGestureRecognizer(swipeDownGestureToHideKeyBoard)

    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.layoutIfNeeded()
         UIView.animate(withDuration: 1) {
             self.addThingViewBottomConstraint.constant = -100
             self.view.layoutIfNeeded()
         }
        
        self.view.removeGestureRecognizer(tapGestureToHideKeyboard)
        self.view.removeGestureRecognizer(swipeDownGestureToHideKeyBoard)
    }
}
