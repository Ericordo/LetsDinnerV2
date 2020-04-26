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
    
    // : RecipeID, CustomOrder
    // Store in an array of set
    var customOrder = [(String,Int)]() {
        didSet {
            lastIndex = customOrder.endIndex
        }
    }
    
    lazy var lastIndex: Int = customOrder.endIndex
    // Order No = lastIndex + 1
        
    // MARK: Create
    func assignRecipeCustomOrder(recipeId: String, order: Int) {
        self.customOrder.append((recipeId, order))
    }
    
    // MARK: Delete
    func removeRecipeCustomOrder(recipeId: String) {
        /**
         Get the recipeId
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
    
    // MARK: Update
    
    func reorderRecipeCustomOrder(sourceOrder: Int, destinationOrder: Int) {
        /**
         Get the recipeId
         find the location of Recipe in customOrder
         store the index
         remove the orginal recipe
         -1 or  +1 the recipe order for
         insert to destination
         */
        
        var sourceIndex: Int!
        var recipeId: String!
        
        for (index, customOrder) in customOrder.enumerated() {
            if sourceOrder == customOrder.1 {
                recipeId = customOrder.0
                sourceIndex = index
            }
        }
                
        if sourceOrder < destinationOrder {
            /**
             Find the array that you need to reorder
             -1 that array
             */
            let selectedCustomOrder = customOrder.filter {
                $0.1 > sourceOrder && $0.1 <= destinationOrder
            }
            
                        
            for index in 0 ... customOrder.count - 1 {
                for selectedCustomOrder in selectedCustomOrder {
                    if customOrder[index].0 == selectedCustomOrder.0 {
                        customOrder[index].1 -= 1
                    }
                }
            }

        } else {
            
            let selectedCustomOrder = customOrder.filter {
                $0.1 < sourceOrder && $0.1 >= destinationOrder
            }
            
            for index in (0 ... customOrder.count - 1).reversed() {
                for selectedCustomOrder in selectedCustomOrder {
                    if customOrder[index].0 == selectedCustomOrder.0 {
                        customOrder[index].1 += 1
                    }
                }
            }
        }
        
        customOrder.remove(at: sourceIndex)
        customOrder.append((recipeId, destinationOrder))
        
        print("Reorder result: \(customOrder)")

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
