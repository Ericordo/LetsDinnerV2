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
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var tasksTableView: UITableView!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var servingsLabel: UILabel!
    @IBOutlet private weak var servingsStepper: UIStepper!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var addThingView: UIView!
    @IBOutlet weak var newThingTextField: UITextField!
    @IBOutlet weak var addThingViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sectionSelectionInput: SectionSelectionInput!
    
    
    weak var delegate: ManagementViewControllerDelegate?
    
    private var tasks = Event.shared.tasks
    private var classifiedTasks = [[Task]]()
    private var expandableTasks = [ExpandableTasks]()
    private var sectionNames = [String]()
    private var servings : Int = 2 {
        didSet {
            servingsLabel.text = "Cooking for \(servings)"
            Event.shared.servings = servings
        }
    }
    
    private var selectedSection : String?
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .managementVC
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(UINib(nibName: CellNibs.taskManagementCell, bundle: nil), forCellReuseIdentifier: CellNibs.taskManagementCell)
        servings = Event.shared.servings
        setupUI()
        setupSwipeGesture()
        
        updateServings(servings: servings)
        newThingTextField.delegate = self
        
        sectionSelectionInput.configureInput(sections: self.sectionNames)
        sectionSelectionInput.sectionSelectionInputDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupUI() {
        progressView.progressTintColor = Colors.newGradientRed
        progressView.trackTintColor = .white
        progressView.progress = 2/5
        progressView.setProgress(3/5, animated: true)
        tasksTableView.tableFooterView = UIView()
        servingsLabel.text = "Cooking for \(servings)"
        servingsStepper.minimumValue = 2
        servingsStepper.maximumValue = 12
        servingsStepper.stepValue = 1
        servingsStepper.value = Double(servings)
        
        if Event.shared.selectedRecipes.isEmpty && Event.shared.selectedCustomRecipes.isEmpty {
            servingsLabel.isHidden = true
            servingsStepper.isHidden = true
            separatorView.isHidden = true
        }
    }
    
    private func setupSwipeGesture() {
        self.view.addSwipeGestureRecognizer(action: {self.delegate?.managementVCDidTapBack(controller: self)})
    }
    
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
    
    @IBAction private func didTapBack(_ sender: UIButton) {
        delegate?.managementVCDidTapBack(controller: self)
    }
    
    @IBAction private func didTapNext(_ sender: UIButton) {
        delegate?.managementVCDdidTapNext(controller: self)
    }
    
    @IBAction private func didTapAdd(_ sender: UIButton) {
        self.selectedSection = "Miscellaneous"
        newThingTextField.becomeFirstResponder()
 
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
    
    @IBAction func didTapStepper(_ sender: UIStepper) {
        updateServings(servings: Int(sender.value))
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1) {
            self.addThingViewBottomConstraint.constant = keyboardFrame.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.layoutIfNeeded()
         UIView.animate(withDuration: 1) {
             self.addThingViewBottomConstraint.constant = -80
             self.view.layoutIfNeeded()
         }
        
    }
    

}

extension ManagementViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if Event.shared.tasks.count == 0 {
            tableView.setEmptyView(title: LabelStrings.noTaskTitle, message: LabelStrings.noTaskMessage)
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
        if (editingStyle == .delete) {
            let taskToDelete = expandableTasks[indexPath.section].tasks[indexPath.row]
            let index = Event.shared.tasks.firstIndex { (task) -> Bool in
                taskToDelete.taskName == task.taskName && taskToDelete.parentRecipe == task.parentRecipe
            }
            
            Event.shared.tasks.remove(at: index!)
            expandableTasks[indexPath.section].tasks.remove(at: indexPath.row)
            if expandableTasks[indexPath.section].tasks.count == 0 {
                expandableTasks.remove(at: indexPath.section)
                sectionNames.remove(at: indexPath.section)
            }
//
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
     
      
        }
        
    }
    
// MARK: Add for sections and collapsable rows
    
     func numberOfSections(in tableView: UITableView) -> Int {
        
        if Event.shared.tasks.count == 0 {
                  tableView.setEmptyView(title: LabelStrings.noTaskTitle, message: LabelStrings.noTaskMessage)
              } else {
              tableView.restore()
              }
        
        return expandableTasks.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .white
        headerView.tag = section
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCloseCollapse)))
        
//        let collapseButton : UIButton = {
//            let button = UIButton()
//            button.setImage(UIImage(named: "collapse"), for: .normal)
//            if !expandableTasks[section].isExpanded {
//                button.transform = CGAffineTransform(rotationAngle: -CGFloat((Double.pi/2)))
//            }
//            button.tag = section
//            button.addTarget(self, action: #selector(handleCloseCollapse), for: .touchUpInside)
//            return button
//        }()
        
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
            view.backgroundColor = UIColor.lightGray
            return view
        }()
        
        let progressCircle = ProgressCircle(frame: CGRect(origin: .zero, size: CGSize(width: 25, height: 25)))
     
        
//        headerView.addSubview(collapseButton)
        headerView.addSubview(collapseImage)
        headerView.addSubview(progressCircle)
        headerView.addSubview(nameLabel)
        headerView.addSubview(separator)
        
//        collapseButton.translatesAutoresizingMaskIntoConstraints = false
//        collapseButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
//        collapseButton.heightAnchor.constraint(equalToConstant: 29).isActive = true
//        collapseButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
//        collapseButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0).isActive = true
        
        collapseImage.translatesAutoresizingMaskIntoConstraints = false
        collapseImage.widthAnchor.constraint(equalToConstant: 15).isActive = true
        collapseImage.heightAnchor.constraint(equalToConstant: 15).isActive = true
        collapseImage.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10).isActive = true
        collapseImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0).isActive = true
        
        progressCircle.translatesAutoresizingMaskIntoConstraints = false
        progressCircle.widthAnchor.constraint(equalToConstant: 25).isActive = true
        progressCircle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        progressCircle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
//        progressCircle.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
//        progressCircle.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
//        progressCircle.trailingAnchor.constraint(equalTo: collapseButton.leadingAnchor, constant: -5).isActive = true
        progressCircle.trailingAnchor.constraint(equalTo: collapseImage.leadingAnchor, constant: -5).isActive = true
       
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
//        nameLabel.trailingAnchor.constraint(equalTo: collapseButton.leadingAnchor, constant: -10).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: progressCircle.leadingAnchor, constant: 0).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
        separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        
//        number of completed task in section / number of task in section
        var numberOfCompletedTasks = 0
        expandableTasks[section].tasks.forEach { task in
            if task.taskState == .completed {
                numberOfCompletedTasks += 1
            }
        }
        let percentage : Double = Double(numberOfCompletedTasks)/Double(expandableTasks[section].tasks.count)
        progressCircle.animate(percentage: percentage)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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

extension ManagementViewController: SectionSelectionInputDelegate {
    func updateSelectedSection(sectionName: String) {
        self.selectedSection = sectionName
    }
    
    
}

extension ManagementViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !newThingTextField.text!.isEmpty {
            let newTask = Task(taskName: textField.text!,
                               assignedPersonUid: "nil",
                               taskState: TaskState.unassigned.rawValue,
                               taskUid: "nil",
                               assignedPersonName: "nil",
                               isCustom: true,
                               parentRecipe: self.selectedSection ?? "Miscellaneous")
            Event.shared.tasks.append(newTask)
            self.prepareData()
            self.tasksTableView.reloadData()
        }
        newThingTextField.text = ""
        return newThingTextField.resignFirstResponder()
        
    }
    
}
