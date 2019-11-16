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
        
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(UINib(nibName: CellNibs.taskManagementCell, bundle: nil), forCellReuseIdentifier: CellNibs.taskManagementCell)
        setupUI()
        
        //        tasksTableView.tableFooterView = UIView()
        
    }
    
    private func setupUI() {
        progressView.progressTintColor = Colors.newGradientRed
        progressView.trackTintColor = .white
        progressView.progress = 2/4
        progressView.setProgress(3/4, animated: true)
        
        
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
            let newTask = Task(taskName: textField.text!,
                               assignedPersonUid: "nil",
                               taskState: TaskState.unassigned.rawValue,
                               taskUid: "",
                               assignedPersonName: "nil")
            newTask.isCustom = true
            Event.shared.tasks.append(newTask)
            self.tasksTableView.reloadData()
            
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

        return Event.shared.tasks.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let taskManagementCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskManagementCell, for: indexPath) as! TaskManagementCell
        let task = Event.shared.tasks[indexPath.row]
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
            let task = Event.shared.tasks[indexPath.row]
            let index = Event.shared.tasks.firstIndex {  comparedTask -> Bool in
                task.taskName == comparedTask.taskName
            }
            Event.shared.tasks.remove(at: index!)
            tasksTableView.deleteRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
        }
        
    }
    
}
