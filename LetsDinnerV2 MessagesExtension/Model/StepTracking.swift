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
    case eventSummaryVC
    case tasksListVC
}

class StepStatus {
    static var currentStep: StepTracking?
}
