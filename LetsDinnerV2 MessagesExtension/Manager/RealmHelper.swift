//
//  RealmHelper.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift
import CloudKit

class RealmHelper {
    
    static let shared = RealmHelper()
    
    private let realm = try! Realm()
    
    private init() {}
    
    func loadCustomRecipes() -> Results<CustomRecipe>? {
        return realm.objects(CustomRecipe.self)
    }
    
    private func loadCustomIngredients() -> Results<CustomIngredient>? {
        return realm.objects(CustomIngredient.self)
    }
    
    func saveRecipeInRealm(_ recipe: LDRecipe, recordID: String) -> SignalProducer<Void, LDError> {
        return SignalProducer { observer, _ in
            let recipeModel = self.convertLDRecipeToRLRecipe(recipe)
            recipeModel.recordId = recordID
            do {
                try self.realm.write {
                    self.realm.add(recipeModel)
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            } catch {
                observer.send(error: .recipeSaveRealmFail)
            }
        }
    }
    
    func updateRecipeInRealm(_ currentRecipe: LDRecipe, _ newRecipe: LDRecipe) -> SignalProducer<Void, LDError> {
        let convertedCurrentRecipe = self.convertLDRecipeToRLRecipe(currentRecipe)
        let predicate = NSPredicate(format: "id == %@", convertedCurrentRecipe.id)
        let realmNewRecipe = self.convertLDRecipeToRLRecipe(newRecipe)
        return SignalProducer { observer, _ in
            DispatchQueue.main.async {
                do {
                    try self.realm.write {
                        let realmCurrentRecipeResults = self.realm.objects(CustomRecipe.self).filter(predicate)
                        let realmCurrentRecipe = realmCurrentRecipeResults.first
                        if let realmCurrentRecipe = realmCurrentRecipe {
                            realmCurrentRecipe.title = realmNewRecipe.title
                            realmCurrentRecipe.downloadUrl = realmNewRecipe.downloadUrl
                            realmCurrentRecipe.servings = realmNewRecipe.servings
                            realmCurrentRecipe.comments.removeAll()
                            realmCurrentRecipe.comments.append(objectsIn: realmNewRecipe.comments)
                            realmCurrentRecipe.cookingSteps.removeAll()
                            realmCurrentRecipe.cookingSteps.append(objectsIn: realmNewRecipe.cookingSteps)
                            realmCurrentRecipe.ingredients.removeAll()
                            realmCurrentRecipe.ingredients.append(objectsIn: realmNewRecipe.ingredients)
                            realmCurrentRecipe.isPublic = realmNewRecipe.isPublic
                        }
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                } catch {
                    observer.send(error: .recipeUpdateRealmFail)
                }
            }
        }
    }
    
    func deleteRecipeInRealm(_ recipe: LDRecipe) -> SignalProducer<Void, LDError> {
        return SignalProducer { observer, _ in
            let realmRecipe = self.convertLDRecipeToRLRecipe(recipe)
            let predicate = NSPredicate(format: "id == %@", realmRecipe.id)
            DispatchQueue.main.async {
                do {
                    try self.realm.write {
                        let recipeToDelete = self.realm.objects(CustomRecipe.self).filter(predicate)
                        self.realm.delete(recipeToDelete)
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                } catch {
                    observer.send(error: .recipeDeleteRealmFail)
                }
            }
        }
    }
    
    func deleteAllRecipes() {
        do {
            let recipes = self.loadCustomRecipes()
            let ingredients = self.loadCustomIngredients()
            try self.realm.write {
                if let recipes = recipes {
                    self.realm.delete(recipes)
                }
                if let ingredients = ingredients {
                    self.realm.delete(ingredients)
                }
            }
        } catch {
            #if DEBUG
            print(error.localizedDescription)
            #endif
        }
    }
    
    func transferCloudRecipesToRealm(_ recipes: [LDRecipe]) -> SignalProducer<Void, LDError> {
        self.deleteAllRecipes()
        return SignalProducer { observer, _ in
            let realmRecipes = recipes.map { self.convertLDRecipeToRLRecipe($0) }
            do {
                try self.realm.write {
                    self.realm.add(realmRecipes)
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            } catch {
                observer.send(error: .transferToRealmFail)
            }
        }
    }
    
    func convertRLRecipeToLDRecipe(_ recipe: CustomRecipe) -> LDRecipe {
        let ingredients = recipe.ingredients
        var convertedIngredients = [LDIngredient]()
        ingredients.forEach { ingredient in
            convertedIngredients.append(self.convertRLIngredientToLDIngredient(ingredient))
        }
        let steps = recipe.cookingSteps
        var convertedSteps = [String]()
        steps.forEach { step in
            convertedSteps.append(step)
        }
        let comments = recipe.comments
        var convertedComments = [String]()
        comments.forEach { comment in
            convertedComments.append(comment)
        }
        var ckRecordID : CKRecord.ID? = nil
        if let recordId = recipe.recordId {
            ckRecordID = CKRecord.ID(recordName: recordId)
        }
        let LDrecipe = LDRecipe(id: recipe.id,
                                title: recipe.title,
                                servings: recipe.servings,
                                downloadUrl: recipe.downloadUrl,
                                cookingSteps: convertedSteps,
                                comments: convertedComments,
                                ingredients: convertedIngredients,
                                isPublic: recipe.isPublic,
                                recordID: ckRecordID)
        return LDrecipe
    }
    
    func convertRLIngredientToLDIngredient(_ ingredient: CustomIngredient) -> LDIngredient {
        var ckRecordID : CKRecord.ID? = nil
        if let recordId = ingredient.recordId {
            ckRecordID = CKRecord.ID(recordName: recordId)
        }
        let LDingredient = LDIngredient(name: ingredient.name,
                                        amount: ingredient.amount.value,
                                        unit: ingredient.unit,
                                        recordID: ckRecordID)
        return LDingredient
    }
    
    private func convertLDRecipeToRLRecipe(_ recipe: LDRecipe) -> CustomRecipe {
        let customRecipe = CustomRecipe()
        customRecipe.title = recipe.title
        customRecipe.id = recipe.id
        customRecipe.servings = recipe.servings
        customRecipe.downloadUrl = recipe.downloadUrl
        recipe.cookingSteps.forEach { step in
            customRecipe.cookingSteps.append(step)}
        recipe.comments.forEach { comment in
            customRecipe.comments.append(comment)
        }
        recipe.ingredients.forEach { ingredient in
            customRecipe.ingredients.append(convertLDIngredientToRLIngredient(ingredient))
        }
        customRecipe.isPublic = recipe.isPublic
        customRecipe.recordId = recipe.recordID?.recordName
        return customRecipe
    }
    
    private func convertLDIngredientToRLIngredient(_ ingredient: LDIngredient) -> CustomIngredient {
        let customIngredient = CustomIngredient()
        customIngredient.name = ingredient.name
        customIngredient.amount.value = ingredient.amount
        customIngredient.unit = ingredient.unit
        customIngredient.recordId = ingredient.recordID?.recordName
        return customIngredient
    }
}
