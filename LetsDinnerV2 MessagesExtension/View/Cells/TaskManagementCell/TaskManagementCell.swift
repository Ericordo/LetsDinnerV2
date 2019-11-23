//
//  TaskManagementCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class TaskManagementCell: UITableViewCell {
    
    @IBOutlet weak var taskStatusButton: TaskStatusButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var personLabel: TaskPersonLabel!
    
    var task: Task?
    
    func configureCell(task: Task, indexPath: Int) {
        self.task = task
        taskNameLabel.text = task.taskName
        taskStatusButton.setState(state: task.taskState)
        
        if task.taskState == .assigned || task.taskState == .completed {
                   if Event.shared.currentUser?.identifier != task.assignedPersonUid {
                       personLabel.text = task.assignedPersonName
                       personLabel.setTextAttributes(taskIsOwnedByUser: false)
                   } else {
                       if task.taskState == .completed {
                           personLabel.text = MessagesToDisplay.completed
                       } else {
                           personLabel.text = MessagesToDisplay.assignedToYourself
                       }
                       personLabel.setTextAttributes(taskIsOwnedByUser: true)
                   }
               } else {
            personLabel.setTextAttributes(taskIsOwnedByUser: false)
            personLabel.text = MessagesToDisplay.noAssignment
               }
               taskStatusButton.isUserInteractionEnabled = false
    }
    
    func didTapTaskStatusButton() {
        guard let task = task else { return }
        switch task.taskState {
        case .unassigned:
            personLabel.setTextAttributes(taskIsOwnedByUser: true)
            task.assignedPersonName = defaults.username
            task.assignedPersonUid = Event.shared.currentUser?.identifier
            task.taskState = .assigned
            personLabel.text = MessagesToDisplay.assignedToYourself
        case .assigned:
            task.taskState = .completed
            task.assignedPersonName = defaults.username
            task.assignedPersonUid = Event.shared.currentUser?.identifier
            personLabel.text = MessagesToDisplay.completed
        case .completed:
            personLabel.setTextAttributes(taskIsOwnedByUser: false)
            task.taskState = .unassigned
            task.assignedPersonName = "nil"
            task.assignedPersonUid = "nil"
            personLabel.text = MessagesToDisplay.noAssignment
        }
        taskStatusButton.setState(state: task.taskState)
        if let index = Event.shared.tasks.firstIndex(where: { $0.taskName == task.taskName }) {
            Event.shared.tasks[index] = task
        }
       
    }
    
    
}
