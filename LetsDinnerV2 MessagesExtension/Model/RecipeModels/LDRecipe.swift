//
//  LDRecipe.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import CloudKit

struct LDRecipe: Equatable, Codable {
    var id = UUID().uuidString
    var title: String = ""
    var servings: Int = 2
    var downloadUrl: String?
    var cookingSteps: [String] = [String]()
    var comments: [String] = [String]()
    var ingredients: [LDIngredient] = [LDIngredient]()
    var keywords: [String] = [String]()
    var isPublic: Bool = false
    var recordID: CKRecord.ID? = nil
    
    var isSelected : Bool {
        return Event.shared.selectedCustomRecipes.contains { $0.id == self.id }
    }
    
    var isPublicAndSelected : Bool {
        return Event.shared.selectedPublicRecipes.contains { $0.id == self.id }
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, servings, downloadUrl, cookingSteps, comments, ingredients, keywords, isPublic
    }
    
    static func == (lhs: LDRecipe, rhs: LDRecipe) -> Bool {
        return lhs.title == rhs.title &&
            lhs.servings == rhs.servings &&
            lhs.downloadUrl == rhs.downloadUrl &&
            lhs.cookingSteps == rhs.cookingSteps &&
            lhs.ingredients == rhs.ingredients &&
            lhs.comments == rhs.comments &&
            lhs.keywords == rhs.keywords &&
            lhs.isPublic == rhs.isPublic
    }
}

