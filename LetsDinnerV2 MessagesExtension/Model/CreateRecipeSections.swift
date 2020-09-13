//
//  CreateRecipeSections.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 20/4/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

enum CreateRecipeSections: String {
    case name = "Name"
    case ingredient = "Ingredient"
    case step = "Cooking Step"
    case comment = "Comment"
    
    var title : String {
        switch self {
        case .name:
            return ""
        case .ingredient:
            return LabelStrings.ingredients
        case .step:
            return LabelStrings.cookingSteps
        case .comment:
            return LabelStrings.tipsAndComments.uppercased()
        }
    }
    
    var placeholder : String {
        switch self {
        case .name:
            return ""
        case .ingredient:
            return LabelStrings.ingredientPlaceholder
        case .step:
            return LabelStrings.stepPlaceholder
        case .comment:
            return LabelStrings.cookingTipPlaceholder
        }
    }
}
