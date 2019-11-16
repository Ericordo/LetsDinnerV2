//
//  TasksListViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol TasksListViewControllerDelegate: class {
    func tasksListVCDidTapBackButton(controller: TasksListViewController)
    func tasksListVCDidTapSubmit(controller: TasksListViewController)
}

class TasksListViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tasksTableView: UITableView!
    
    weak var delegate: TasksListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .tasksListVC
        setupUI()
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(UINib(nibName: CellNibs.taskCell, bundle: nil), forCellReuseIdentifier: CellNibs.taskCell)
    }
    
    func setupUI() {
        backButton.setTitle(" \(Event.shared.dinnerName)", for: .normal)
        submitButton.layer.masksToBounds = true
        submitButton.alpha = 0.5
        submitButton.layer.cornerRadius = 12
        submitButton.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
    }


    @IBAction func didTapBack(_ sender: UIButton) {
        let difference = Event.shared.tasks.difference(from: Event.shared.currentConversationTaskStates)
        if !difference.isEmpty {
            let alert = UIAlertController(title: MessagesToDisplay.unsubmittedTasks, message: MessagesToDisplay.submitQuestion, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: MessagesToDisplay.yes, style: .default, handler: { action in
                self.didTapSubmit(self.submitButton)
            }))
            alert.addAction(UIAlertAction(title: MessagesToDisplay.no, style: .destructive, handler: { action in
                var newTasks = [Task]()
                Event.shared.currentConversationTaskStates.forEach { task in
                    
                    let newTask = Task(taskName: task.taskName, assignedPersonUid: task.assignedPersonUid, taskState: task.taskState.rawValue, taskUid: task.taskUid, assignedPersonName: task.assignedPersonName)
                    newTask.isCustom = task.isCustom
                    newTasks.append(newTask)
                }
                Event.shared.tasks = newTasks
                self.delegate?.tasksListVCDidTapBackButton(controller: self)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            self.delegate?.tasksListVCDidTapBackButton(controller: self)
        }
    }
    
    @IBAction func didTapSubmit(_ sender: UIButton) {
        delegate?.tasksListVCDidTapSubmit(controller: self)
    }
    
    
}

extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if Event.shared.tasks.count == 0 {
            tableView.setEmptyView(title: LabelStrings.nothingToDo, message: "")
        } else {
            tableView.restore()
        }

        return Event.shared.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskCell, for: indexPath) as! TaskCell
        let task = Event.shared.tasks[indexPath.row]
        taskCell.configureCell(task: task, indexPath: indexPath.row)
        taskCell.delegate = self
        return taskCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let cell = tableView.cellForRow(at: indexPath) as! TaskCell
         cell.didTapTaskStatusButton()
     }
    
    
}

extension TasksListViewController: TaskCellDelegate {
    func taskCellDidTapTaskStatusButton() {
        let difference = Event.shared.tasks.difference(from: Event.shared.currentConversationTaskStates)
        if !difference.isEmpty {
            submitButton.isEnabled = true
            submitButton.alpha = 1.0
        } else {
            submitButton.isEnabled = false
            submitButton.alpha = 0.5
        }
        Event.shared.summary = "\(defaults.username) updated \(Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()) tasks."
    }
    
    
}
