//
//  TaskPersonLabel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class TaskPersonLabel: UILabel {
    
    let taskIsOwnedByUserFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
    let taskIsOwnedByUserTextColor = Colors.customPink
    
    let regularFont = UIFont.systemFont(ofSize: 13)
    let regularTextColor = Colors.customGray

    func setTextAttributes(taskIsOwnedByUser: Bool) {
        switch taskIsOwnedByUser {
        case true:
            font = taskIsOwnedByUserFont
            textColor = taskIsOwnedByUserTextColor
        case false:
            font = regularFont
            textColor = regularTextColor
        }
    }
}
