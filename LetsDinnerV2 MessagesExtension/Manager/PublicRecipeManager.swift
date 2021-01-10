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
                .child(DataKeys.membersRecipes)
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
        var publicRecipes : [PublicRecipe] = []
        value.forEach { (key, value) in
            if let publicRecipe = self.parsePublicRecipe(recipeId: key, value as! [String : Any]) {
                publicRecipes.append(publicRecipe)
            }
        }
        return publicRecipes.filter { $0.validated }.map { $0.recipe }
    }
    
    private func parsePublicRecipe(recipeId: String, _ value: [String : Any]) -> PublicRecipe? {
        var recipe = LDRecipe()
        recipe.id = recipeId
        guard let language = value[DataKeys.language] as? String,
              let isValidated = value[DataKeys.isValidated] as? Bool,
              let recipeDict = value[DataKeys.recipe] as? [String : Any],
              let servings = recipeDict[DataKeys.servings] as? Int,
              let title = recipeDict[DataKeys.title] as? String
        else { return nil }
        recipe.title = title
        recipe.servings = servings
        if let comments = recipeDict[DataKeys.comments] as? [String] {
            recipe.comments = comments
        }
        if let cookingSteps = recipeDict[DataKeys.cookingSteps] as? [String] {
            recipe.cookingSteps = cookingSteps
        }
        if let downloadUrl = recipeDict[DataKeys.downloadUrl] as? String {
            recipe.downloadUrl = downloadUrl
        }
        if let ingredients = recipeDict[DataKeys.ingredients] as? [String : [String : Any]] {
            ingredients.forEach { key, value in
                let name = key
                var amount: Double?
                var unit: String?
                if let ingredientAmount = value[DataKeys.amount] as? Double {
                    amount = ingredientAmount
                }
                if let ingredientUnit = value[DataKeys.unit] as? String, !ingredientUnit.isEmpty {
                    unit = ingredientUnit
                }
                let customIngredient = LDIngredient(name: name, amount: amount, unit: unit)
                recipe.ingredients.append(customIngredient)
            }
        }
        return PublicRecipe(recipe: recipe,
                            validated: isValidated,
                            language: language)
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
        let languageString = self.prepareLanguageString(recipe)
        let language = NSLinguisticTagger.dominantLanguage(for: languageString) ?? "en"
        let publicRecipeInfo : [String : Any] = [DataKeys.recipe : recipeInfo,
                                                 DataKeys.isValidated : false,
                                                 DataKeys.language : language]
        return publicRecipeInfo
    }
    
    private func prepareLanguageString(_ recipe: LDRecipe) -> String {
        var languageString = recipe.title
        recipe.comments.forEach { comment in
            languageString.append(" \(comment)")
        }
        recipe.cookingSteps.forEach { cookingStep in
            languageString.append(" \(cookingStep)")
        }
        recipe.ingredients.forEach { ingredient in
            languageString.append(" \(ingredient.name)")
        }
        return languageString
    }

    func saveRecipe(_ recipe: LDRecipe) -> SignalProducer<Void, LDError> {
        let recipeInfo = self.createRecipeInfo(recipe)
        return SignalProducer { observer, _ in
            self.database
                .child(DataKeys.membersRecipes)
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
                .child(DataKeys.membersRecipes)
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
                .child(DataKeys.membersRecipes)
                .child(recipe.id)
                .removeValue { _, _ in
                    observer.send(value: ())
                    observer.sendCompleted()
                }
        }
    }
}
