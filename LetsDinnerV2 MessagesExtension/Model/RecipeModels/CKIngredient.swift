//
//  CKIngredient.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 08/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import CloudKit

struct CKIngredient {
    var name: String = ""
    var amount: Double? = nil
    var unit: String? = nil
    var parentRecipe: CKRecord.Reference? = nil
    var recordID : CKRecord.ID? = nil
}
