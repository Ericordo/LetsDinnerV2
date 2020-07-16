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
    
//    var userIsOnCloud = false
    
    private init() {}
    
//    func userOnCloud(completion: @escaping (Bool) -> Void) {
//        CKContainer.default().accountStatus { status, error in
//            if error != nil {
//                completion(false)
//            }
//            if status == .available {
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }
//    }
    
    
    
//    func checkUserCloudStatus(completion: @escaping () -> Void) {
//        CKContainer.default().accountStatus { (status, error) in
//            guard error == nil else { return }
//            switch status {
//            case .available:
//                self.userIsOnCloud = true
//            case .couldNotDetermine, .noAccount, .restricted:
//                self.userIsOnCloud = false
//            @unknown default:
//                self.userIsOnCloud = false
//            }
//            completion()
//        }
//    }
    
    func userIsLoggedIn() -> SignalProducer<Bool, Error> {
        return SignalProducer { observer, _ in
            CKContainer.default().accountStatus { (status, error) in
                if let error = error {
                    observer.send(error: error)
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
    
    func retrieveUserStatusOnCloudAndUpdateFirebase() {
        
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
    
    private func saveRecipeInCloud(recipe: LDRecipe) -> SignalProducer<CKRecord.ID, Error> {
        return SignalProducer { observer, _ in
            let record = self.prepareRecipeCKRecord(recipe)
            
            self.privateDatabase.save(record) { (savedRecord, error) in
                if let error = error {
                    observer.send(error: error)
                }
                if let recordId = savedRecord?.recordID {
                    observer.send(value: recordId)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    private func saveRecipeIngredientsInCloud(_ ingredients: [LDIngredient]?, for recipeRecordId: CKRecord.ID) -> SignalProducer<CKRecord.ID, Error> {
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
                     if let error = error {
                        observer.send(error: error)
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
    
    func saveRecipeAndIngredientsOnCloud(_ recipe: LDRecipe) -> SignalProducer<CKRecord.ID, Error> {
        return saveRecipeInCloud(recipe: recipe).flatMap(.latest) { recordId -> SignalProducer<CKRecord.ID, Error> in
            return self.saveRecipeIngredientsInCloud(recipe.ingredients, for: recordId)
        }
    }

    //MARK: Fetch Recipes
    private func fetchCKRecipesFromCloud() -> SignalProducer<[CKRecord],Error> {
        return SignalProducer { observer, _ in
            let predicate = NSPredicate(value: true)
            let sort = NSSortDescriptor(key: "creationDate", ascending: false)
            let query = CKQuery(recordType: "CustomRecipe", predicate: predicate)
            query.sortDescriptors = [sort]
            self.privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error as? CKError {
                    observer.send(error: error)
                } else if error != nil {
                    observer.send(error: error!)
                }
                guard let records = records else { return }
                observer.send(value: records)
                observer.sendCompleted()
            }
        }
    }
    
    private func fetchCKIngredientsFromCloud(for recordID: CKRecord.ID) -> SignalProducer<[CKRecord],Error> {
        return SignalProducer { observer, _ in
            let predicate = NSPredicate(format: "parentRecipe = %@", recordID)
            let sort = NSSortDescriptor(key: "creationDate", ascending: false)
            let query = CKQuery(recordType: "CustomIngredient", predicate: predicate)
            query.sortDescriptors = [sort]
            
            self.privateDatabase.perform(query, inZoneWith: nil) { [weak self] (records, error) in
                 guard let self = self else { return }
                 if let error = error as? CKError {
                     self.dealWithCloudKitError(error)
                 } else if error != nil {
                    observer.send(error: error!)
                 }
                guard let records = records else { return }
                observer.send(value: records)
                observer.sendCompleted()
             }
        }
    }
    
    func fetchLDRecipesFromCloud() -> SignalProducer<[LDRecipe],Error> {
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
    func deleteRecipeFromCloud(_ recipe: LDRecipe) -> SignalProducer<Void,Error> {
        return SignalProducer { observer, _ in
            guard let recordID = recipe.recordID else { return }
            self.privateDatabase.delete(withRecordID: recordID) { (_, error) in
                if let error = error {
                    observer.send(error: error)
                } else {
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
        }
    }
    
    // MARK: Update Recipe
    func updateRecipeInCloud(_ currentRecipe: LDRecipe, _ newRecipe: LDRecipe) -> SignalProducer<Void,Error> {
        return SignalProducer { observer, _ in
            guard let recordID = currentRecipe.recordID else { return }
            
            self.privateDatabase.fetch(withRecordID: recordID) { (record, error) in
                if let error = error {
                    observer.send(error: error)
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
                    if let error = error {
                        observer.send(error: error)
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
                if let error = error {
                    observer.send(error: error)
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
        
//        func convertModelRecipesToRealmRecipes(_ modelRecipes: [CustomRecipeModel]) -> [CustomRecipe] {
//            var customRecipes = [CustomRecipe]()
//            modelRecipes.forEach { modelRecipe in
//                let customRecipe = CustomRecipe()
//                customRecipe.title = modelRecipe.title
//                customRecipe.id = modelRecipe.id
//                customRecipe.downloadUrl = modelRecipe.downloadUrl
//                customRecipe.servings = modelRecipe.servings
//                customRecipe.comments = modelRecipe.comments
//                let cookingSteps = List<String>()
//                customRecipe.cookingSteps.forEach { step in
//                    cookingSteps.append(step)
//                }
//                customRecipe.cookingSteps = cookingSteps
//                if let modelIngredients = modelRecipe.ingredients {
//                    customRecipe.ingredients = self.convertModelIngredientsToRealmIngredients(modelIngredients)
//                }
//                customRecipes.append(customRecipe)
//            }
//            return customRecipes
//        }
        
//        func convertModelIngredientsToRealmIngredients(_ modelIngredients: [CustomIngredientModel]) -> List<CustomIngredient>{
//            let customIngredients = List<CustomIngredient>()
//            modelIngredients.forEach { modelIngredient in
//                let customIngredient = CustomIngredient()
//                customIngredient.name = modelIngredient.name
//                customIngredient.amount.value = modelIngredient.amount
//                customIngredient.unit = modelIngredient.unit
//                customIngredients.append(customIngredient)
//            }
//            return customIngredients
//        }
        
        func convertCloudIngredientToRealmIngredient(_ cloudIngredient: CKRecord) -> CustomIngredient {
            
            return CustomIngredient()
        }
        
        func dealWithError(_ error: Error) {
            
        }
        
        func dealWithCloudKitError(_ error: CKError) {
            switch error.code {
            case .alreadyShared:
                print("already shared")
            case .internalError:
                print("already shared")
            case .partialFailure:
                print("already shared")
            case .networkUnavailable:
                print("already shared")
            case .networkFailure:
                print("already shared")
            case .badContainer:
                print("already shared")
            case .serviceUnavailable:
                print("already shared")
            case .requestRateLimited:
                print("already shared")
            case .missingEntitlement:
                print("already shared")
            case .notAuthenticated:
                print("already shared")
            case .permissionFailure:
                print("already shared")
            case .unknownItem:
                print("already shared")
            case .invalidArguments:
                print("already shared")
                print(error.localizedDescription)
                print(error.errorCode)
            case .resultsTruncated:
                print("already shared")
            case .serverRecordChanged:
                print("already shared")
            case .serverRejectedRequest:
                print("already shared")
            case .assetFileNotFound:
                print("already shared")
            case .assetFileModified:
                print("already shared")
            case .incompatibleVersion:
                print("already shared")
            case .constraintViolation:
                print("already shared")
            case .operationCancelled:
                print("already shared")
            case .changeTokenExpired:
                print("already shared")
            case .batchRequestFailed:
                print("already shared")
            case .zoneBusy:
                print("already shared")
            case .badDatabase:
                print("already shared")
            case .quotaExceeded:
                print("already shared")
            case .zoneNotFound:
                print("already shared")
            case .limitExceeded:
                print("already shared")
            case .userDeletedZone:
                print("already shared")
            case .tooManyParticipants:
                print("already shared")
            case .referenceViolation:
                print("already shared")
            case .managedAccountRestricted:
                print("already shared")
            case .participantMayNeedVerification:
                print("already shared")
            case .serverResponseLost:
                print("already shared")
            case .assetNotAvailable:
                print("already shared")
            @unknown default:
                  print("already shared")
            }
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
