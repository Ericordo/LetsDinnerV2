//
//  LDRecipe.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import CloudKit

struct LDRecipe {
    var id = UUID().uuidString
    var title: String = ""
    var servings: Int = 0
    var downloadUrl: String?
    var cookingSteps: [String] = [String]()
    var comments: String?
    var ingredients: [LDIngredient] = [LDIngredient]()
    var recordID: CKRecord.ID?
    
    var isSelected : Bool {
        return Event.shared.selectedCustomRecipes.contains { $0.id == self.id }
    }
}

