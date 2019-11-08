//
//  TaskCVCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class TaskCVCell: UICollectionViewCell {

    @IBOutlet weak var taskStatusButton: TaskStatusButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var personLabel: TaskPersonLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var task: Task?
    
    func configureCell(task: Task) {
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
            personLabel.text = ""
        }
        guard let currentUser = Event.shared.currentUser else { return }
        if task.taskState == .assigned || task.taskState == .completed {
            isUserInteractionEnabled = task.assignedPersonUid == currentUser.identifier
            taskStatusButton.isEnabled = task.assignedPersonUid == currentUser.identifier
        } else {
            taskStatusButton.isEnabled = true
            isUserInteractionEnabled = true
        }
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
           guard let task = task else { return }
           if task.assignedPersonUid == "nil" {
               personLabel.isHidden = true
           } else {
               personLabel.isHidden = false
           }
       }
    
    
    

}
