//
//  CloudManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 13/02/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import CloudKit
import RealmSwift
import ReactiveSwift

class CloudManager {
    
    static let shared = CloudManager()
    
    let keyValStore = NSUbiquitousKeyValueStore()
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    private init() {}
    
    func userIsLoggedIn() -> SignalProducer<Bool, LDError> {
        return SignalProducer { observer, _ in
            CKContainer.default().accountStatus { (status, error) in
                if error != nil {
                    observer.send(error: .notSignedInCloud)
                }
                switch status {
                case .available:
                    observer.send(value: true)
                default:
                    observer.send(value: false)
                }
                observer.sendCompleted()
            }
        }
    }
    
    func saveUserInfoOnCloud(_ info: String, key: String) {
        keyValStore.set(info, forKey: key)
        keyValStore.synchronize()
    }
    
    func retrieveUserInfoOnCloud(key: String) -> String? {
        return keyValStore.string(forKey: key)
    }
    
    func retrieveProfileInfo() {
        if let username = retrieveUserInfoOnCloud(key: Keys.username), !username.isEmpty {
            defaults.username = username
        }
        if let address = retrieveUserInfoOnCloud(key: Keys.address), !address.isEmpty {
            defaults.address = address
        }
        if let profilePicUrl = retrieveUserInfoOnCloud(key: Keys.profilePicUrl), !profilePicUrl.isEmpty {
            defaults.profilePicUrl = profilePicUrl
        }
        if let measurementSystem = retrieveUserInfoOnCloud(key: Keys.measurementSystem), !measurementSystem.isEmpty {
            defaults.measurementSystem = measurementSystem
            print(measurementSystem)
        }
    }
    
    func retrieveUserIdOnCloud() -> String? {
        return keyValStore.string(forKey: Keys.userUid)
    }
    
    func removeUserInfoOnCloud(key: String) {
        keyValStore.removeObject(forKey: key)
    }
    
    // MARK: Save Recipe
    private func prepareRecipeCKRecord(_ recipe: LDRecipe) -> CKRecord {
        let record = CKRecord(recordType: "CustomRecipe")
        record[.title] = recipe.title
        record[.id] = recipe.id
        record[.servings] = recipe.servings
        if let downloadUrl = recipe.downloadUrl {
            record[.downloadUrl] = downloadUrl
        }
        record[.cookingSteps] = recipe.cookingSteps
        record[.tips] = recipe.comments
        return record
    }
    
    private func prepareIngredientCKRecord(_ ingredient: LDIngredient, for recipeRecordId: CKRecord.ID) -> CKRecord {
        let record = CKRecord(recordType: "CustomIngredient")
        let reference = CKRecord.Reference(recordID: recipeRecordId, action: .deleteSelf)
        record[.name] = ingredient.name
        if let amount = ingredient.amount {
            record[.amount] = amount
        }
        if let unit = ingredient.unit {
            record[.unit] = unit
        }
        record[.parentRecipe] = reference
        return record
    }
    
    private func saveRecipeInCloud(recipe: LDRecipe) -> SignalProducer<CKRecord.ID, LDError> {
        return SignalProducer { observer, _ in
            let record = self.prepareRecipeCKRecord(recipe)
            
            self.privateDatabase.save(record) { (savedRecord, error) in
                if error != nil {
                    observer.send(error: .recipeSaveCloudFail)
                }
                if let recordId = savedRecord?.recordID {
                    observer.send(value: recordId)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    private func saveRecipeIngredientsInCloud(_ ingredients: [LDIngredient]?, for recipeRecordId: CKRecord.ID) -> SignalProducer<CKRecord.ID, LDError> {
        let dispatchGroup = DispatchGroup()
        return SignalProducer { observer, _ in
            guard let ingredients = ingredients else {
                observer.send(value: recipeRecordId)
                observer.sendCompleted()
                return
            }
            ingredients.forEach { ingredient in
                dispatchGroup.enter()
                let record = self.prepareIngredientCKRecord(ingredient, for: recipeRecordId)
                self.privateDatabase.save(record) { (savedRecord, error) in
                     if error != nil {
                        observer.send(error: .recipeSaveCloudFail)
                     }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                observer.send(value: recipeRecordId)
                observer.sendCompleted()
            }
        }
    }
    
    func saveRecipeAndIngredientsOnCloud(_ recipe: LDRecipe) -> SignalProducer<CKRecord.ID, LDError> {
        return saveRecipeInCloud(recipe: recipe).flatMap(.concat) { recordId -> SignalProducer<CKRecord.ID, LDError> in
            return self.saveRecipeIngredientsInCloud(recipe.ingredients, for: recordId)
        }
    }

    //MARK: Fetch Recipes
    private func fetchCKRecipesFromCloud() -> SignalProducer<[CKRecord], LDError> {
        return SignalProducer { observer, _ in
            let predicate = NSPredicate(value: true)
            let sort = NSSortDescriptor(key: "creationDate", ascending: false)
            let query = CKQuery(recordType: "CustomRecipe", predicate: predicate)
            query.sortDescriptors = [sort]
            self.privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                if error != nil {
                    observer.send(error: .recipeFetchCloudFail)
                }
                guard let records = records else { return }
                observer.send(value: records)
                observer.sendCompleted()
            }
        }
    }
    
    private func fetchCKIngredientsFromCloud(for recordID: CKRecord.ID) -> SignalProducer<[CKRecord], LDError> {
        return SignalProducer { observer, _ in
            let predicate = NSPredicate(format: "parentRecipe = %@", recordID)
            let sort = NSSortDescriptor(key: "creationDate", ascending: false)
            let query = CKQuery(recordType: "CustomIngredient", predicate: predicate)
            query.sortDescriptors = [sort]
            
            self.privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                 if error != nil {
                    observer.send(error: .recipeFetchCloudFail)
                }
                guard let records = records else { return }
                observer.send(value: records)
                observer.sendCompleted()
             }
        }
    }
    
    func fetchLDRecipesFromCloud() -> SignalProducer<[LDRecipe], LDError> {
        let dispatchGroup = DispatchGroup()
        var recipes = [CKRecipe]()
        return SignalProducer { observer, _ in
            self.fetchCKRecipesFromCloud()
                .startWithResult { (result) in
                    switch result {
                    case .failure(let error):
                        observer.send(error: error)
                    case .success(let records):
                        records.forEach { recipeRecord in
                            dispatchGroup.enter()
                            self.fetchCKIngredientsFromCloud(for: recipeRecord.recordID)
                                .startWithResult { result in
                                    switch result {
                                    case .failure(let error):
                                        observer.send(error: error)
                                    case .success(let ingredientRecords):
                                        var recipe = self.convertCKRecordToCKRecipe(recipeRecord)
                                        let ingredients = self.convertCKRecordsToCKIngredients(ingredientRecords)
                                        recipe.ingredients = ingredients
                                        recipe.ingredients.sort { $0.name.uppercased() < $1.name.uppercased() }
                                        recipes.append(recipe)
                                    }
                                    dispatchGroup.leave()
                            }
                        }
                        dispatchGroup.notify(queue: .main) {
                            observer.send(value: recipes.map({ self.convertCKRecipeToLDRecipe($0) }))
                            observer.sendCompleted()
                        }
                    }
            }
            
        }
    }
    
    // MARK: Delete Recipe
    func deleteRecipeFromCloud(_ recipe: LDRecipe) -> SignalProducer<Void, LDError> {
        return SignalProducer { observer, _ in
            guard let recordID = recipe.recordID else { return }
            self.privateDatabase.delete(withRecordID: recordID) { (_, error) in
                if error != nil {
                    observer.send(error: .recipeDeleteCloudFail)
                } else {
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
        }
    }
    
    // MARK: Update Recipe
    func updateRecipeInCloud(_ currentRecipe: LDRecipe, _ newRecipe: LDRecipe) -> SignalProducer<Void, LDError> {
        return SignalProducer { observer, _ in
            guard let recordID = currentRecipe.recordID else { return }
            
            self.privateDatabase.fetch(withRecordID: recordID) { (record, error) in
                if error != nil {
                    observer.send(error: .recipeUpdateCloudFail)
                }
                guard let record = record else { return }
                record[.id] = currentRecipe.id
                record[.title] = newRecipe.title
                record[.servings] = newRecipe.servings
                if let downloadUrl = newRecipe.downloadUrl {
                    record[.downloadUrl] = downloadUrl
                }
                record[.cookingSteps] = newRecipe.cookingSteps
                record[.tips] = newRecipe.comments
                
                self.privateDatabase.save(record) { (_, error) in
                    if error != nil {
                        observer.send(error: .recipeUpdateCloudFail)
                    }
                }
            }
            
            var currentIngredientsRecordIDs = [CKRecord.ID]()
            currentRecipe.ingredients.forEach { ingredient in
                if let recordID = ingredient.recordID {
                    currentIngredientsRecordIDs.append(recordID)
                }
            }
            
            var newIngredientsRecords = [CKRecord]()
            newRecipe.ingredients.forEach { ingredient in
                let record = CKRecord(recordType: "CustomIngredient")
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                record[.name] = ingredient.name
                record[.amount] = ingredient.amount
                record[.unit] = ingredient.unit
                record[.parentRecipe] = reference
                newIngredientsRecords.append(record)
            }
            
            let saveRecordsOperation = CKModifyRecordsOperation(recordsToSave: newIngredientsRecords, recordIDsToDelete: currentIngredientsRecordIDs)
            
            saveRecordsOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if error != nil {
                    observer.send(error: .recipeUpdateCloudFail)
                } else {
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
            
            self.privateDatabase.add(saveRecordsOperation)
        }
    }
    
    // MARK: Conversion
    private func convertCKRecordToCKRecipe(_ record: CKRecord) -> CKRecipe {
        guard record.recordType == "CustomRecipe" else { return CKRecipe() }
        var recipe = CKRecipe()
        if let title = record.value(forKey: LDRecipeKey.title.rawValue) as? String {
            recipe.title = title
        }
        if let id = record.value(forKey: LDRecipeKey.id.rawValue) as? String {
            recipe.id = id
        }
        if let servings = record.value(forKey: LDRecipeKey.servings.rawValue) as? Int {
            recipe.servings = servings
        }
        if let downloadUrl = record.value(forKey: LDRecipeKey.downloadUrl.rawValue) as? String {
            recipe.downloadUrl = downloadUrl
        }
        if let comments = record.value(forKey: LDRecipeKey.tips.rawValue) as? [String] {
            recipe.comments = comments
        }
        if let cloudCookingSteps = record.value(forKey: LDRecipeKey.cookingSteps.rawValue) as? [String] {
            recipe.cookingSteps = cloudCookingSteps
        }
        recipe.recordID = record.recordID
        
        return recipe
    }
    
    func convertCKRecipeToLDRecipe(_ cloudRecipe: CKRecipe) -> LDRecipe {
        return LDRecipe(id: cloudRecipe.id,
                              title: cloudRecipe.title,
                              servings: cloudRecipe.servings,
                              downloadUrl: cloudRecipe.downloadUrl,
                              cookingSteps: cloudRecipe.cookingSteps,
                              comments: cloudRecipe.comments,
                              ingredients: cloudRecipe.ingredients.map({ self.convertCKIngredientToLDIngredient($0) }),
                              recordID: cloudRecipe.recordID)
    }
    
    private func convertCKIngredientToLDIngredient(_ cloudIngredient: CKIngredient) -> LDIngredient {
        return LDIngredient(name: cloudIngredient.name,
                            amount: cloudIngredient.amount,
                            unit: cloudIngredient.unit,
                            recordID: cloudIngredient.recordID)
    }
    
    func convertCKRecordsToCKIngredients(_ records: [CKRecord]) -> [CKIngredient] {
        var ingredients = [CKIngredient]()
        records.forEach { record in
            var ingredient = CKIngredient()
            if let name = record.value(forKey: LDIngredientKey.name.rawValue) as? String {
                ingredient.name = name
            }
            if let amount = record.value(forKey: LDIngredientKey.amount.rawValue) as? Double {
                ingredient.amount = amount
            }
            if let unit = record.value(forKey: LDIngredientKey.unit.rawValue) as? String {
                ingredient.unit = unit
            }
            if let reference = record.value(forKey: LDIngredientKey.parentRecipe.rawValue) as? CKRecord.Reference {
                ingredient.parentRecipe = reference
            }
            ingredient.recordID = record.recordID
            ingredients.append(ingredient)
        }
        return ingredients
    }
        
        func convertCloudRecipeToRealmRecipe(_ cloudRecipe: CKRecord) -> CustomRecipe {
            guard cloudRecipe.recordType == "CustomRecipe" else { return CustomRecipe() }
            let customRecipe = CustomRecipe()
            if let title = cloudRecipe.value(forKey: LDRecipeKey.title.rawValue) as? String {
                customRecipe.title = title
            }
            if let id = cloudRecipe.value(forKey: LDRecipeKey.id.rawValue) as? String {
                customRecipe.id = id
            }
            if let servings = cloudRecipe.value(forKey: LDRecipeKey.servings.rawValue) as? Int {
                customRecipe.servings = servings
            }
            if let downloadUrl = cloudRecipe.value(forKey: LDRecipeKey.downloadUrl.rawValue) as? String {
                customRecipe.downloadUrl = downloadUrl
            }
            var comments = [String]()
            if let cloudComments = cloudRecipe.value(forKey: LDRecipeKey.tips.rawValue) as? [String] {
                comments = cloudComments
            }
            comments.forEach { comment in
                customRecipe.comments.append(comment)
            }
            var cookingSteps = [String]()
            if let cloudCookingSteps = cloudRecipe.value(forKey: LDRecipeKey.cookingSteps.rawValue) as? [String] {
                cookingSteps = cloudCookingSteps
            }
            cookingSteps.forEach { step in
                customRecipe.cookingSteps.append(step)
            }
            return CustomRecipe()
        }

}

enum LDRecipeKey : String {
    case title
    case id
    case servings
    case ingredients
    case downloadUrl
    case cookingSteps
    case comments
    case tips
}

enum LDIngredientKey: String {
    case name
    case amount
    case unit
    case parentRecipe
}

extension CKRecord {
    subscript(key: LDRecipeKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
    
    subscript(key: LDIngredientKey) -> Any? {
         get {
             return self[key.rawValue]
         }
         set {
             self[key.rawValue] = newValue as? CKRecordValue
         }
     }
}
