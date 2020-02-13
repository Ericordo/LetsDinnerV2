//
//  StepTracking.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

enum StepTracking {
    case initialVC
    case registrationVC
    case newEventVC
    case recipesVC
    case recipeDetailsVC
    case managementVC
    case eventDescriptionVC
    case reviewVC
    case eventSummaryVC
    case tasksListVC
    case eventInfoVC
    case expiredEventVC
}

class StepStatus {
    static var currentStep: StepTracking?
}


enum ProgressVC: Int {
    case registrationViewController = 1
    case recipesViewController = 2
    case managementViewController = 3
    case eventDescriptionViewController = 4
    case reviewViewController = 5
}
