//
//  CKRecipe.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 08/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import CloudKit

struct CKRecipe {
    var title: String = ""
    var id: String = ""
    var servings: Int = 0
    var downloadUrl: String? = nil
    var cookingSteps: [String] = [String]()
    var comments: [String] = [String]()
    var ingredients: [CKIngredient] = [CKIngredient]()
    var keywords: [String] = [String]()
    var isPublic: Bool = false
    var recordID: CKRecord.ID? = nil
}




