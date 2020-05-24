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
    @IBOutlet weak var separatorLine: UIView!
    
    var task: Task?
    var count : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(task: Task, count: Int) {
        
        self.isUserInteractionEnabled = true
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
                taskStatusButton.setColorAttributes(ownedByUser: false, taskState: task.taskState)
            } else {
                // My Task
                if task.taskState == .completed {
                    personLabel.text = AlertStrings.completed
                } else {
                    personLabel.text = AlertStrings.assignedToMyself
                }
                personLabel.setTextAttributes(taskIsOwnedByUser: true)
                taskStatusButton.setColorAttributes(ownedByUser: true, taskState: task.taskState)
            }
            
        } else {
            // Task Not Assigned
            personLabel.text = AlertStrings.noAssignment
            personLabel.setTextAttributes(taskIsOwnedByUser: false)
        }
        
        // For deleting the line for the bottom last cell
        separatorLine.isHidden = false
        separatorLine.backgroundColor = UIColor.cellSeparatorLine
        
        if count % 3 == 0 {
            separatorLine.isHidden = true
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
