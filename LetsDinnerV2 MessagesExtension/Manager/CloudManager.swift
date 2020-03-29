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

class CloudManager {
    
    static let shared = CloudManager()
    
    let keyValStore = NSUbiquitousKeyValueStore()
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    var userIsOnCloud = false
    
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
    
    func checkUserCloudStatus(completion: @escaping () -> Void) {
        CKContainer.default().accountStatus { (status, error) in
            guard error == nil else { return }
            switch status {
            case .available:
                self.userIsOnCloud = true
            case .couldNotDetermine, .noAccount, .restricted:
                self.userIsOnCloud = false
            @unknown default:
                self.userIsOnCloud = false 
            }
        }
    }
    
//    func fetchUserRecord() {
//        CKContainer.default().fetchUserRecordID { (recordID, error) in
//            guard let recordID = recordID, error == nil else { return }
//            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
//                guard let record = record, error == nil else { return }
//
//            }
//        }
//    }
    
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
    
    func saveCustomRecipeOnCloud(customRecipe: CustomRecipe, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
//        guard userIsOnCloud else { return }
        let record = CKRecord(recordType: "CustomRecipe")
        record[.title] = customRecipe.title
        record[.id] = customRecipe.id
        record[.servings] = customRecipe.servings
        if let downloadUrl = customRecipe.downloadUrl {
            record[.downloadUrl] = downloadUrl
        }
        var cookingSteps = [String]()
        customRecipe.cookingSteps.forEach { step in
            cookingSteps.append(step)
        }
        record[.cookingSteps] = cookingSteps
        record[.comments] = customRecipe.comments
        
        privateDatabase.save(record) { (savedRecord, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else {
                if let recordId = savedRecord?.recordID {
                    DispatchQueue.main.async {
                        completion(.success(recordId))
                    }
                }
            }
        }
    }
    
    func saveIngredientsForCustomRecipeOnCloud(customRecipeRecordId: CKRecord.ID, ingredients: [TemporaryIngredient], completion: @escaping (Result<Void, Error>) -> Void) {
//        guard userIsOnCloud else { return }
        ingredients.forEach { ingredient in
            let record = CKRecord(recordType: "CustomIngredient")
            let reference = CKRecord.Reference(recordID: customRecipeRecordId, action: .deleteSelf)
            record[.name] = ingredient.name
            if let amount = ingredient.amount {
                record[.amount] = amount
            }
            if let unit = ingredient.unit {
                record[unit] = unit
            }
            record[.parentRecipe] = reference
            
            privateDatabase.save(record) { (savedRecord, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
            }
        }
        
        
    }
    
        private func fetchCustomRecipesOnCloud(completion: @escaping (Result<[CKRecord], Error>) -> Void) {
            let predicate = NSPredicate(value: true)
            let sort = NSSortDescriptor(key: "creationDate", ascending: false)
            let query = CKQuery(recordType: "CustomRecipe", predicate: predicate)
            query.sortDescriptors = [sort]
            
    //        Check how to use operation, seems to be used to fetch all in one, better.
    //        let operation = CKQueryOperation(query: query)
            
    //        var customRecipes = [CustomRecipe]()
    //        var customRecipesModel = [CustomRecipeModel]()
            
            privateDatabase.perform(query, inZoneWith: nil) { [weak self] (records, error) in
                guard let self = self else { return }
                if let error = error as? CKError {
                    self.dealWithCloudKitError(error)
                } else if error != nil {
                    DispatchQueue.main.async {
                         completion(.failure(error!))
                    }
                }
                guard let records = records else { return }
                completion(.success(records))
    //            records.forEach { record in
    ////                customRecipes.append(self.convertCloudRecipeToRealmRecipe(record))
    //                customRecipesModel.append(self.convertCloudRecipeToRecipeModel(record))
    //            }
    //            completion(.success(customRecipesModel))

            }
            
    //        operation.recordFetchedBlock = { record in
    //            let customRecipe = CustomRecipe()
    //
    //        }
            
        }
        
        private func fetchCorrespondingCustomIngredientsOnCloud(for recordID: CKRecord.ID?, completion: @escaping (Result<[CustomIngredientModel], Error>) -> Void) {
            guard let recordID = recordID else { return }
            let predicate = NSPredicate(format: "parentRecipe = %@", recordID)
            let sort = NSSortDescriptor(key: "creationDate", ascending: false)
            let query = CKQuery(recordType: "CustomIngredient", predicate: predicate)
            query.sortDescriptors = [sort]
            
            var customIngredientsModel = [CustomIngredientModel]()
            
            privateDatabase.perform(query, inZoneWith: nil) { [weak self] (records, error) in
                guard let self = self else { return }
                if let error = error as? CKError {
                    self.dealWithCloudKitError(error)
                } else if error != nil {
                    DispatchQueue.main.async {
                        completion(.failure(error!))
                    }
                }
                guard let records = records else { return }
                customIngredientsModel = self.convertCloudIngredientsToIngredientsModel(records)
                completion(.success(customIngredientsModel))
            }
        }
        
        struct CustomRecipeModel {
            var title: String = ""
            var id: String = ""
            var servings: Int = 0
            var downloadUrl: String? = nil
            var cookingSteps: [String]? = nil
            var comments: String? = nil
            var ingredients: [CustomIngredientModel]? = nil
            var recordID: CKRecord.ID? = nil
        }
        
        struct CustomIngredientModel {
            var name: String = ""
            var amount: Double? = nil
            var unit: String? = nil
            var parentRecipe: CKRecord.Reference? = nil
        }
        

        
    //    func fetchIngredientsForCustomRecipeOnCloud() {
    //
    //    }
        
        func convertCloudRecipeToRecipeModel(_ cloudRecipe: CKRecord) -> CustomRecipeModel {
            guard cloudRecipe.recordType == "CustomRecipe" else { return CustomRecipeModel() }
            var customRecipe = CustomRecipeModel()
            if let title = cloudRecipe.value(forKey: CustomRecipeKey.title.rawValue) as? String {
                customRecipe.title = title
            }
            if let id = cloudRecipe.value(forKey: CustomRecipeKey.id.rawValue) as? String {
                customRecipe.id = id
            }
            if let servings = cloudRecipe.value(forKey: CustomRecipeKey.servings.rawValue) as? Int {
                customRecipe.servings = servings
            }
            if let downloadUrl = cloudRecipe.value(forKey: CustomRecipeKey.downloadUrl.rawValue) as? String {
                customRecipe.downloadUrl = downloadUrl
            }
            if let comments = cloudRecipe.value(forKey: CustomRecipeKey.comments.rawValue) as? String {
                customRecipe.comments = comments
            }
            if let cloudCookingSteps = cloudRecipe.value(forKey: CustomRecipeKey.cookingSteps.rawValue) as? [String] {
                customRecipe.cookingSteps = cloudCookingSteps
            }
            customRecipe.recordID = cloudRecipe.recordID
     
            return customRecipe
        }
        
        func convertCloudIngredientsToIngredientsModel(_ cloudIngredients: [CKRecord]) -> [CustomIngredientModel] {
            var customIngredients = [CustomIngredientModel]()
            cloudIngredients.forEach { cloudIngredient in
                var customIngredient = CustomIngredientModel()
                if let name = cloudIngredient.value(forKey: CustomIngredientKey.name.rawValue) as? String {
                    customIngredient.name = name
                }
                if let amount = cloudIngredient.value(forKey: CustomIngredientKey.amount.rawValue) as? Double {
                    customIngredient.amount = amount
                }
                if let unit = cloudIngredient.value(forKey: CustomIngredientKey.unit.rawValue) as? String {
                    customIngredient.unit = unit
                }
                if let reference = cloudIngredient.value(forKey: CustomIngredientKey.parentRecipe.rawValue) as? CKRecord.Reference {
                    customIngredient.parentRecipe = reference
                }
                customIngredients.append(customIngredient)
            }
            return customIngredients
        }
        
        func convertRecipeModelToRealmRecipe(_ modelRecipe: CustomRecipeModel) -> CustomRecipe {
            
            return CustomRecipe()
        }
        
        func fetchRecipesAndIngredientsFromCloud(completion: @escaping (Result<[CustomRecipe], Error>) -> Void) {
    //        fetchRecipesWithoutIngredients
            self.fetchCustomRecipesOnCloud { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let cloudRecipes):
                    //        convertRecipesToModelObject
                    var customRecipesModel = [CustomRecipeModel]()
                    cloudRecipes.forEach { cloudRecipe in
                        customRecipesModel.append(self.convertCloudRecipeToRecipeModel(cloudRecipe))
                    }
                    //        fetchCorrespondingIngredients
                    //        convertIngredientsToModelObjects
                    var updatedCustomRecipesModel = [CustomRecipeModel]()
                    customRecipesModel.forEach { customRecipeModel in
                        self.fetchCorrespondingCustomIngredientsOnCloud(for: customRecipeModel.recordID) { result in
                            switch result {
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            case .success(let customIngredientsModel):
                                var updatedCustomRecipeModel = customRecipeModel
                                updatedCustomRecipeModel.ingredients = customIngredientsModel
                                updatedCustomRecipesModel.append(updatedCustomRecipeModel)
                               
                                
                            }
                        }
                    }
                     //        convertModelObjectsToRealmRecipes
                    DispatchQueue.main.async {
                        completion(.success(self.convertModelRecipesToRealmRecipes(updatedCustomRecipesModel)))
                    }
                    
                    
                    
                    
                }
            }



        }
        
        func convertCloudRecipeToRealmRecipe(_ cloudRecipe: CKRecord) -> CustomRecipe {
            guard cloudRecipe.recordType == "CustomRecipe" else { return CustomRecipe() }
            let customRecipe = CustomRecipe()
            if let title = cloudRecipe.value(forKey: CustomRecipeKey.title.rawValue) as? String {
                customRecipe.title = title
            }
            if let id = cloudRecipe.value(forKey: CustomRecipeKey.id.rawValue) as? String {
                customRecipe.id = id
            }
            if let servings = cloudRecipe.value(forKey: CustomRecipeKey.servings.rawValue) as? Int {
                customRecipe.servings = servings
            }
            if let downloadUrl = cloudRecipe.value(forKey: CustomRecipeKey.downloadUrl.rawValue) as? String {
                customRecipe.downloadUrl = downloadUrl
            }
            if let comments = cloudRecipe.value(forKey: CustomRecipeKey.comments.rawValue) as? String {
                customRecipe.comments = comments
            }
            var cookingSteps = [String]()
            if let cloudCookingSteps = cloudRecipe.value(forKey: CustomRecipeKey.cookingSteps.rawValue) as? [String] {
                cookingSteps = cloudCookingSteps
            }
            cookingSteps.forEach { step in
                customRecipe.cookingSteps.append(step)
            }
            return CustomRecipe()
        }
        
        func convertModelRecipesToRealmRecipes(_ modelRecipes: [CustomRecipeModel]) -> [CustomRecipe] {
            var customRecipes = [CustomRecipe]()
            modelRecipes.forEach { modelRecipe in
                let customRecipe = CustomRecipe()
                customRecipe.title = modelRecipe.title
                customRecipe.id = modelRecipe.id
                customRecipe.downloadUrl = modelRecipe.downloadUrl
                customRecipe.servings = modelRecipe.servings
                customRecipe.comments = modelRecipe.comments
                let cookingSteps = List<String>()
                customRecipe.cookingSteps.forEach { step in
                    cookingSteps.append(step)
                }
                customRecipe.cookingSteps = cookingSteps
                if let modelIngredients = modelRecipe.ingredients {
                    customRecipe.ingredients = self.convertModelIngredientsToRealmIngredients(modelIngredients)
                }
                customRecipes.append(customRecipe)
            }
            return customRecipes
        }
        
        func convertModelIngredientsToRealmIngredients(_ modelIngredients: [CustomIngredientModel]) -> List<CustomIngredient>{
            let customIngredients = List<CustomIngredient>()
            modelIngredients.forEach { modelIngredient in
                let customIngredient = CustomIngredient()
                customIngredient.name = modelIngredient.name
                customIngredient.amount.value = modelIngredient.amount
                customIngredient.unit = modelIngredient.unit
                customIngredients.append(customIngredient)
            }
            return customIngredients
        }
        
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

enum CustomRecipeKey : String {
    case title
    case id
    case servings
    case ingredients
    case downloadUrl
    case cookingSteps
    case comments
}

enum CustomIngredientKey: String {
    case name
    case amount
    case unit
    case parentRecipe
}

extension CKRecord {
    subscript(key: CustomRecipeKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
    
    subscript(key: CustomIngredientKey) -> Any? {
         get {
             return self[key.rawValue]
         }
         set {
             self[key.rawValue] = newValue as? CKRecordValue
         }
     }
}
