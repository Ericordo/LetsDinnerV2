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
    case selectedRecipesVC
    case managementVC
    case eventDescriptionVC
    case reviewVC
    case eventSummaryVC
    case tasksListVC
    case eventInfoVC
    case expiredEventVC
}

extension StepTracking : CaseIterable {
    var stepNumber : Int {
        switch self {
        case .registrationVC:
            return 0
        case .newEventVC:
            return 1
        case .recipesVC:
            return 2
        case .managementVC:
            return 3
        case .eventDescriptionVC:
            return 4
        case .reviewVC:
            return 5
        default:
            return 0
        }
    }
}

class StepStatus {
    static var currentStep: StepTracking?
}
