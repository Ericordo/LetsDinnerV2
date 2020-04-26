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
    
    // For storage
    // Key: RecipeID - String
    // Value: CustomOrder
    
    // Store in an array of set
    // Should be in Order
    var customOrder = [(String,Int)]() {
        didSet {
            lastIndex = customOrder.endIndex
            print(customOrder)

        }
    }
    
    lazy var lastIndex: Int = customOrder.endIndex
    // Order No = lastIndex + 1
    
//    var customOrderArray = [Int]()
    
    func assignRecipeCustomOrder(recipeId: String, order: Int) {
        self.customOrder.append((recipeId, order))
    }
    
    func removeRecipeCustomOrder(recipeId: String) {
        /** Get the recipeId
         Find the location of Recipe in customOrder
         Remove the Reicpe from customOrder
         Reassign the old recipe
         */
        
        var removedIndex: Int?
        
        for (index, recipe) in customOrder.enumerated() {
            if recipeId == recipe.0 {
                removedIndex = index
                customOrder.remove(at: index)
            }
        }

        // Reorder the later index
        guard let index = removedIndex else { return }
        guard lastIndex - index >= 1 else { return }
        
        for index in index ... lastIndex - 1 {
            customOrder[index].1 = customOrder[index].1 - 1
        }

    }
    
    func reorderRecipeIdToArray() {
        
    }
    
    func findLastIndex() {
        self.lastIndex = customOrder.endIndex
    }
    
    func checkIfRecipeIsCustom(recipeId: String) -> SearchType? {
        if !Event.shared.selectedRecipes.isEmpty {
            for recipe in Event.shared.selectedRecipes {
                if recipeId == String(recipe.id!) {
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
    
    
    
    // Rearrange the data by editing the index
    
}
