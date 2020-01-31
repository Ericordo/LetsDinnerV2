//
//  TaskManagementCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol TaskManagementCellDelegate: class {
    func taskManagementCellDidTapTaskStatusButton(indexPath: IndexPath)
}

class TaskManagementCell: UITableViewCell {
    
    @IBOutlet weak var taskStatusButton: TaskStatusButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var personLabel: TaskPersonLabel!
    @IBOutlet weak var seperatorLine: UIView!
    
    var task: Task?
    
     weak var delegate: TaskManagementCellDelegate?
    
    func configureCell(task: Task) {
        self.task = task
        if let amount = task.metricAmount {
            if amount.truncatingRemainder(dividingBy: 1) == 0.0 {
                if let unit = task.metricUnit {
                    taskNameLabel.text = "\(task.taskName), \(String(format:"%.0f", amount)) \(unit)"
                } else {
                    taskNameLabel.text = "\(task.taskName), \(String(format:"%.0f", amount))"
                }
            } else {
                if let unit = task.metricUnit {
                    taskNameLabel.text = "\(task.taskName), \(String(format:"%.1f", amount)) \(unit)"
                } else {
                    taskNameLabel.text = "\(task.taskName), \(String(format:"%.1f", amount))"
                }
            }
        } else {
            taskNameLabel.text = task.taskName
        }
        taskStatusButton.setState(state: task.taskState)
        
        if task.taskState == .assigned || task.taskState == .completed {
                   if Event.shared.currentUser?.identifier != task.assignedPersonUid {
                       personLabel.text = task.assignedPersonName
                       personLabel.setTextAttributes(taskIsOwnedByUser: false)
                   } else {
                       if task.taskState == .completed {
                           personLabel.text = MessagesToDisplay.completed
                       } else {
                           personLabel.text = MessagesToDisplay.assignedToMyself
                       }
                       personLabel.setTextAttributes(taskIsOwnedByUser: true)
                   }
               } else {
            personLabel.setTextAttributes(taskIsOwnedByUser: false)
            personLabel.text = MessagesToDisplay.noAssignment
        }
        
        taskStatusButton.isUserInteractionEnabled = false
        
        seperatorLine.backgroundColor = Colors.seperatorGrey
    }
    
    func didTapTaskStatusButton(indexPath: IndexPath) {
   
        guard let task = task else { return }
        switch task.taskState {
        case .unassigned:
            personLabel.setTextAttributes(taskIsOwnedByUser: true)
            task.assignedPersonName = defaults.username
            task.assignedPersonUid = Event.shared.currentUser?.identifier
            task.taskState = .assigned
            personLabel.text = MessagesToDisplay.assignedToMyself
        case .assigned:
            task.taskState = .completed
            task.assignedPersonName = defaults.username
            task.assignedPersonUid = Event.shared.currentUser?.identifier
            personLabel.text = MessagesToDisplay.completed
            delegate?.taskManagementCellDidTapTaskStatusButton(indexPath: indexPath)
        case .completed:
            personLabel.setTextAttributes(taskIsOwnedByUser: false)
            task.taskState = .unassigned
            task.assignedPersonName = "nil"
            task.assignedPersonUid = "nil"
            personLabel.text = MessagesToDisplay.noAssignment
            delegate?.taskManagementCellDidTapTaskStatusButton(indexPath: indexPath)
        }
        taskStatusButton.setState(state: task.taskState)
        if let index = Event.shared.tasks.firstIndex(where: { $0.taskName == task.taskName }) {
            Event.shared.tasks[index] = task
        }
    }
    
    
}
