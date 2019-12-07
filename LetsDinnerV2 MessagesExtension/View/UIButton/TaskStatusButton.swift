//
//  TaskStatusButton.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class TaskStatusButton: UIButton {
    let unassignedImage = UIImage(named: "unassignedTask")
    let assignedImage = UIImage(named: "assignedTask")
    let completedImage = UIImage(named: "completedTask")

    func setState(state: TaskState) {
        switch state {
        case .unassigned:
            setImage(unassignedImage, for: .normal)
        case .assigned:
            setImage(assignedImage, for: .normal)
        case .completed:
            setImage(completedImage, for: .normal)
        }
    }
    
}

