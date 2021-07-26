//
//  Recipe.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

struct Recipe : Codable {
    var title: String
    var imageUrl: String?
    var sourceUrl: String?
    var ingredientList: [Ingredient]?
    var servings: Int?
    var id: String
    var instructions: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case title, imageUrl, sourceUrl, ingredientList, servings, id, instructions
    }
    
    
    init(title: String, sourceUrl: String, id: String) {
        self.sourceUrl = sourceUrl
        self.title = title
        self.id = id
    }
        
    init(dict: Dictionary<String, Any>) {
        self.title = dict["title"] as? String ?? LabelStrings.recipe
        if let imageUrl = dict["image"] as? String {
            self.imageUrl = imageUrl
        }
        if let sourceUrl = dict["sourceUrl"] as? String {
            self.sourceUrl = sourceUrl
        }
        if let servings = dict["servings"] as? Int {
            self.servings = servings
        }
        if let id = dict["id"] as? Int {
            self.id = String(id)
        } else {
            self.id = UUID().uuidString
        }
        if let ingredients = dict["extendedIngredients"] as? [[String:Any]] {
            var ingredientList = [Ingredient]()
            ingredients.forEach { ingredient in
                var newIngredient = Ingredient()
                if let name = ingredient["name"] as? String {
                    newIngredient.name = name
                }
                if let measures = ingredient["measures"] as? [String : Any] {
                    if let measuresUS = measures["us"] as? [String : Any] {
                        if let usAmount = measuresUS["amount"] as? Double {
                            newIngredient.usAmount = usAmount
                        }
                        if let usUnit = measuresUS["unitShort"] as? String {
                            newIngredient.usUnit = usUnit
                        }
                    }
                    if let measuresMetric = measures["metric"] as? [String : Any] {
                        if let metricAmount = measuresMetric["amount"] as? Double {
                            newIngredient.metricAmount = metricAmount
                        }
                        if let metricUnit = measuresMetric["unitShort"] as? String {
                            newIngredient.metricUnit = metricUnit
                        }
                    }
                }
                ingredientList.append(newIngredient)
            }
            self.ingredientList = ingredientList
        }

        if let analyzedInstructions = dict["analyzedInstructions"] as? [[String:Any]] {
            var procedure = [String]()
            analyzedInstructions.forEach { analyzedInstruction in
                if let steps = analyzedInstruction["steps"] as? [[String:Any]] {
                    steps.forEach { dict in
                        if let step = dict["step"] as? String {
                            procedure.append(step)
                        }
                    }
                }
            }
            self.instructions = procedure
        }
    }
    
    var isSelected : Bool {
        return Event.shared.selectedRecipes.contains { $0.id == self.id }
    }
}