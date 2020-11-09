//
//  TaskStatusButton.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class TaskStatusButton: UIButton {
    let unassignedImage = Images.checkboxOutlined
    let assignedImage = Images.assignedImage
    let completedImage = Images.completedImage
    let completedByOtherImage = Images.completedByOtherImage
        
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
    
    func setColorAttributes(ownedByUser: Bool, taskState: TaskState) {
        if taskState == .completed {
            switch ownedByUser {
            case true:
                setImage(completedImage, for: .normal)
            case false:
                setImage(completedByOtherImage, for: .normal)
            }
        }
    }
}

