//
//  CustomIngredient.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation
import RealmSwift

class CustomIngredient: Object {
    @objc dynamic var name: String = ""
    var amount = RealmOptional<Double>()
    @objc dynamic var unit: String? = nil
    var parentRecipe = LinkingObjects(fromType: CustomRecipe.self, property: "ingredients")
    // If we want to convert the unit
    //    var metricAmount = RealmOptional<Double>()
    //    var usAmount = RealmOptional<Double>()
    //    @objc dynamic var metricUnit: String? = nil
    //    @objc dynamic var usUnit: String? = nil
}

