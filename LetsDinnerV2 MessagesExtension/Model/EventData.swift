//
//  EventData.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/10/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

struct EventData : Codable {
    let dinnerName : String
    let hostName : String
    let dateTimestamp : Double
    let dinnerLocation : String
    let eventDescription : String
    let selectedRecipes : [Recipe]
    let selectedCustomRecipes : [LDRecipe]
    let selectedPublicRecipes : [LDRecipe]
    let servings : Int
    let tasks : [Task]
    let customOrder : [String : Int]
}
