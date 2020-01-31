//
//  TaskCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol TaskCellDelegate: class {
    func taskCellDidTapTaskStatusButton()
    func taskCellUpdateProgress(indexPath: IndexPath)
}

class TaskCell: UITableViewCell {

    @IBOutlet weak var taskStatusButton: TaskStatusButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var personLabel: TaskPersonLabel!
    @IBOutlet weak var seperatorLine: UIView!
    
    var task: Task?
    var indexPath = 0
    weak var delegate: TaskCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
            delegate?.taskCellUpdateProgress(indexPath: indexPath)
        case .assigned:
            if Event.shared.currentUser?.identifier == task.assignedPersonUid {
                task.taskState = .completed
                task.assignedPersonName = defaults.username
                task.assignedPersonUid = Event.shared.currentUser?.identifier
                personLabel.text = MessagesToDisplay.completed
                delegate?.taskCellUpdateProgress(indexPath: indexPath)
            }
        case .completed:
             if Event.shared.currentUser?.identifier == task.assignedPersonUid {
            task.taskState = .unassigned
            task.assignedPersonName = "nil"
            task.assignedPersonUid = "nil"
            personLabel.text = ""
                delegate?.taskCellUpdateProgress(indexPath: indexPath)
            }
        
        }
        taskStatusButton.setState(state: task.taskState)
        if let index = Event.shared.tasks.firstIndex(where: { $0.taskUid == task.taskUid }) {
            Event.shared.tasks[index] = task
        }
        delegate?.taskCellDidTapTaskStatusButton()
    }
    
    func configureCell(task: Task, indexPath: Int) {
        self.task = task
        self.indexPath = indexPath
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
                taskStatusButton.setColorAttributes(ownedByUser: false, taskState: task.taskState)
            } else {
                if task.taskState == .completed {
                    personLabel.text = MessagesToDisplay.completed
                } else {
                    personLabel.text = MessagesToDisplay.assignedToMyself
                }
                personLabel.setTextAttributes(taskIsOwnedByUser: true)
                taskStatusButton.setColorAttributes(ownedByUser: true, taskState: task.taskState)
            }
        } else {
            personLabel.setTextAttributes(taskIsOwnedByUser: false)
            personLabel.text = MessagesToDisplay.noAssignment
        }
        taskStatusButton.isUserInteractionEnabled = false
        seperatorLine.backgroundColor = Colors.seperatorGrey
    }
    
}
