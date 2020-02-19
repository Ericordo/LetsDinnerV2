//
//  CloudManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 13/02/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import CloudKit

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
    
    func fetchIngredientsForCustomRecipeOnCloud() {
        
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
