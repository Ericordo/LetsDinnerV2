//
//  PublicRecipeManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/01/2021.
//  Copyright © 2021 Eric Ordonneau. All rights reserved.
//

import Foundation
import FirebaseDatabase
import ReactiveSwift

class PublicRecipeManager {
    
    static let shared = PublicRecipeManager()
    
    private init() {}
    
    private let database = Database.database().reference()
    
    func fetchRecipes() -> SignalProducer<[LDRecipe], Never> {
        return SignalProducer { observer, _ in
            self.database
                .child(DataKeys.publicRecipes)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let value = snapshot.value as? [String : Any] else {
                        observer.send(value: [])
                        return }
                let recipes = self.parsePublicRecipes(value)
                observer.send(value: recipes)
                observer.sendCompleted()
            }
        }
    }
    
    private func parsePublicRecipes(_ value: [String : Any]) -> [LDRecipe] {
        return []
    }
    
    private func createRecipeInfo(_ recipe: LDRecipe) -> [String : Any] {
        var recipeInfo : [String : Any] = [DataKeys.title : recipe.title,
                                           DataKeys.servings : recipe.servings]
        if let downloadUrl = recipe.downloadUrl {
            recipeInfo[DataKeys.downloadUrl] = downloadUrl
        }
        if !recipe.comments.isEmpty {
            recipeInfo[DataKeys.comments] = recipe.comments
        }
        if !recipe.cookingSteps.isEmpty {
            recipeInfo[DataKeys.cookingSteps] = recipe.cookingSteps
        }
        var ingredientsInfo: [String : [String : Any]] = [:]
        recipe.ingredients.forEach { ingredient in
            var ingredientInfo : [String : Any] = [:]
            if let amount = ingredient.amount {
                ingredientInfo[DataKeys.amount] = amount
            }
            ingredientInfo[DataKeys.unit] = ingredient.unit ?? ""
            ingredientsInfo[ingredient.name] = ingredientInfo
        }
        if !recipe.ingredients.isEmpty {
            recipeInfo[DataKeys.ingredients] = ingredientsInfo
        }
        let publicRecipeInfo : [String : Any] = [recipe.title : recipeInfo,
                                                 DataKeys.isValidated : false]
        return publicRecipeInfo
    }

    func saveRecipe(_ recipe: LDRecipe) -> SignalProducer<Void, LDError> {
        let recipeInfo = self.createRecipeInfo(recipe)
        return SignalProducer { observer, _ in
            self.database
                .child(DataKeys.publicRecipes)
                .child(recipe.id)
                .setValue(recipeInfo) { error, _ in
                if error != nil {
                    observer.send(error: .publicRecipeUploadFail)
                } else {
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
        }
    }
    
    func updateRecipe(_ recipe: LDRecipe) -> SignalProducer<Void, LDError> {
        let recipeInfo = self.createRecipeInfo(recipe)
        return SignalProducer { observer, _ in
            self.database
                .child(DataKeys.publicRecipes)
                .child(recipe.id)
                .updateChildValues(recipeInfo, withCompletionBlock: { error, _ in
                    if error != nil {
                        observer.send(error: .publicRecipeUpdateFail)
                    } else {
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                })
        }
    }
    
    func deleteRecipe(_ recipe: LDRecipe) -> SignalProducer<Void, Never> {
        return SignalProducer { observer, _ in
            self.database
                .child(DataKeys.publicRecipes)
                .child(recipe.id)
                .removeValue { _, _ in
                    observer.send(value: ())
                    observer.sendCompleted()
                }
        }
    }
}
