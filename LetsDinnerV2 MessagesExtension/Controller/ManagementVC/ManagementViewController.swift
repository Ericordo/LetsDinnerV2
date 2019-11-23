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
    
    weak var delegate: ManagementViewControllerDelegate?
    
    private var tasks = Event.shared.tasks
    private var classifiedTasks = [[Task]]()
    private var expandableTasks = [ExpandableTasks]()
    private var sectionNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .managementVC
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(UINib(nibName: CellNibs.taskManagementCell, bundle: nil), forCellReuseIdentifier: CellNibs.taskManagementCell)
        setupUI()
        prepareData()
        tasksTableView.reloadData()
    }
    
    private func setupUI() {
        progressView.progressTintColor = Colors.newGradientRed
        progressView.trackTintColor = .white
        progressView.progress = 2/5
        progressView.setProgress(3/5, animated: true)
        tasksTableView.tableFooterView = UIView()
    }
    
    private func prepareData() {
        tasks = Event.shared.tasks
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
    
    @IBAction private func didTapBack(_ sender: UIButton) {
        delegate?.managementVCDidTapBack(controller: self)
    }
    
    @IBAction private func didTapNext(_ sender: UIButton) {
        delegate?.managementVCDdidTapNext(controller: self)
    }
    
    @IBAction private func didTapAdd(_ sender: UIButton) {
        var textField = UITextField()
        let alert = UIAlertController(title: MessagesToDisplay.addThing, message: "", preferredStyle: .alert)
        let add = UIAlertAction(title: MessagesToDisplay.add, style: .default) { action in
            if !textField.text!.isEmpty {
            let newTask = Task(taskName: textField.text!,
                               assignedPersonUid: "nil",
                               taskState: TaskState.unassigned.rawValue,
                               taskUid: "",
                               assignedPersonName: "nil",
                               isCustom: true,
                               parentRecipe: "Misc.")
            Event.shared.tasks.append(newTask)
            self.prepareData()
            self.tasksTableView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: MessagesToDisplay.cancel, style: .cancel, handler: nil)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = MessagesToDisplay.thingToAdd
            textField = alertTextField
        }
        alert.addAction(add)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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
          taskManagementCell.configureCell(task: task, indexPath: indexPath.row)
          return taskManagementCell
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskManagementCell = tableView.cellForRow(at: indexPath) as! TaskManagementCell
        taskManagementCell.didTapTaskStatusButton()
    }
      
      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return UITableView.automaticDimension
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
        
        let collapseButton : UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "collapse"), for: .normal)
            if !expandableTasks[section].isExpanded {
                button.transform = CGAffineTransform(rotationAngle: -CGFloat((Double.pi/2)))
            }
            button.tag = section
            button.addTarget(self, action: #selector(handleCloseCollapse), for: .touchUpInside)
            return button
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
        
        headerView.addSubview(collapseButton)
        headerView.addSubview(nameLabel)
        headerView.addSubview(separator)
        
        collapseButton.translatesAutoresizingMaskIntoConstraints = false
        collapseButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        collapseButton.heightAnchor.constraint(equalToConstant: 29).isActive = true
        collapseButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
        collapseButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: collapseButton.trailingAnchor, constant: -10).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
        separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
        separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    @objc func handleCloseCollapse(button: UIButton) {
        button.rotate()
        let section = button.tag
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
