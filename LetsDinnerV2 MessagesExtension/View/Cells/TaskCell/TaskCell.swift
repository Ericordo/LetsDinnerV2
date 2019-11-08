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
}

class TaskCell: UITableViewCell {

    @IBOutlet weak var taskStatusButton: TaskStatusButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var personLabel: TaskPersonLabel!
    
    var task: Task?
    var indexPath = 0
    weak var delegate: TaskCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
            task.taskState = .unassigned
            task.assignedPersonName = "nil"
            task.assignedPersonUid = "nil"
            personLabel.text = ""
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
            personLabel.text = ""
        }
        taskStatusButton.isUserInteractionEnabled = false
    }
    
}
