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
    @IBOutlet weak var seperatorLine: UIView!
    
    var task: Task?
    var count : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(task: Task, count: Int) {
        
        self.isUserInteractionEnabled = false
        self.task = task
        if let amount = task.metricAmount, let unit = task.metricUnit {
            taskNameLabel.text = "\(task.taskName), \(String(format:"%.1f", amount)) \(unit)"
        } else {
            taskNameLabel.text = task.taskName
        }
        taskStatusButton.setState(state: task.taskState)
        
        if task.taskState == .assigned || task.taskState == .completed {
            if Event.shared.currentUser?.identifier != task.assignedPersonUid {
                personLabel.text = task.assignedPersonName
                personLabel.setTextAttributes(taskIsOwnedByUser: false)
            } else {
                // My Task
                if task.taskState == .completed {
                    personLabel.text = MessagesToDisplay.completed
                } else {
                    personLabel.text = MessagesToDisplay.assignedToYourself
                }
                personLabel.setTextAttributes(taskIsOwnedByUser: true)
            }
            
        } else {
            // Task Not Assigned
            personLabel.text = MessagesToDisplay.noAssignment
            personLabel.setTextAttributes(taskIsOwnedByUser: false)
        }
        
        // For deleting the line for the bottom last cell
        seperatorLine.isHidden = false
        if count % 3 == 0 {
            seperatorLine.isHidden = true
        }
        
        
//        guard let currentUser = Event.shared.currentUser else { return }
//        if task.taskState == .assigned || task.taskState == .completed {
//            isUserInteractionEnabled = task.assignedPersonUid == currentUser.identifier
//            taskStatusButton.isEnabled = task.assignedPersonUid == currentUser.identifier
//        } else {
//            taskStatusButton.isEnabled = true
//            isUserInteractionEnabled = true
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        taskNameLabel.sizeToFit()
        
//        guard let task = task else { return }
//        if task.assignedPersonUid == "nil" {
//            personLabel.isHidden = true
//        } else {
//            personLabel.isHidden = false
//        }
    }

}
