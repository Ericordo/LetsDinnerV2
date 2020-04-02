//
//  CustomRecipe.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation
import RealmSwift

class CustomRecipe: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title: String = ""
//    @objc dynamic var imageData: Data? = nil
    @objc dynamic var servings: Int = 0
    @objc dynamic var downloadUrl: String? = nil
    var cookingSteps = List<String>() 
    @objc dynamic var comments: String? = nil
    var ingredients = List<CustomIngredient>()
    var customOrder: Int = 0
    
    func assignCustomOrder(customOrder: Int) {
        self.customOrder = customOrder
    }
}


