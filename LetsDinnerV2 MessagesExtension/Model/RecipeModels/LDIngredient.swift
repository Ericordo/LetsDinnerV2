//
//  LDIngredient.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import CloudKit

struct LDIngredient {
    var name: String = ""
    var amount: Double?
    var unit: String?
    var recordID: CKRecord.ID?
}

