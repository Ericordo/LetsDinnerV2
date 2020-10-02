//
//  CustomOrderHelper.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 25/4/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import Firebase

class CustomOrderHelper {
    
    static let shared = CustomOrderHelper()
    
    private init() {}
    
    var customOrder = [String : Int]()
    
    var newIndex : Int {
        return customOrder.count
    }
        
    // MARK: Create
    func assignRecipeCustomOrder(recipeId: String, order: Int) {
        self.customOrder[recipeId] = order
    }
    
    // MARK: Delete
    func removeRecipeCustomOrder(recipeId: String) {
        guard let value = customOrder[recipeId] else { return }
        customOrder.removeValue(forKey: recipeId)
        for (id, order) in customOrder {
            if order > value {
                customOrder[id] = order - 1
            }
        }
    }
    
    // MARK: Update
    func reorderRecipeCustomOrder(sourceOrder: Int, destinationOrder: Int) {
        guard let key = customOrder.first(where: { $0.value == sourceOrder })?.key else { return }
        
        for (id, order) in customOrder {
            if order > sourceOrder && order <= destinationOrder {
                customOrder[id] = order - 1
            }
            if order < sourceOrder && order >= destinationOrder {
                customOrder[id] = order + 1
            }
            customOrder[key] = destinationOrder
        }
    }
    
    func recipeType(from recipeId: String) -> SearchType? {
        if !Event.shared.selectedRecipes.isEmpty {
            for recipe in Event.shared.selectedRecipes {
                if recipeId == recipe.id {
                    return .apiRecipes
                }
            }
        }
        if !Event.shared.selectedCustomRecipes.isEmpty {
            for recipe in Event.shared.selectedCustomRecipes {
                if recipeId == recipe.id {
                    return .customRecipes
                }
            }
        }
        return nil
    }
    
    // MARK: Recipes Title in order
    func mergeAllRecipeTitlesInCustomOrder() -> [String] {
        var recipeTitles = [String]()
        
        guard !customOrder.isEmpty else { return recipeTitles }
        
        for index in 0...customOrder.count-1 {
            guard let recipeId = customOrder.first(where: { $0.value == index })?.key else { return recipeTitles }
            if let recipe = Event.shared.selectedRecipes.first(where: { $0.id == recipeId }) {
                recipeTitles.append(recipe.title)
            } else if let recipe = Event.shared.selectedCustomRecipes.first(where: { $0.id == recipeId }) {
                recipeTitles.append(recipe.title)
            }
        }
        return recipeTitles
    }
}
