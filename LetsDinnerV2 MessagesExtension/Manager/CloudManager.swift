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
    
    var keyValStore = NSUbiquitousKeyValueStore()
    
    private init() {}
    
    func userOnCloud(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { status, error in
            if error != nil {
                completion(false)
            }
            if status == .available {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func saveUserInfoOnCloud(_ info: String, key: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        keyValStore.set(info, forKey: key)
        keyValStore.synchronize()
        
    }
    
    
    

    
    
    
    
    
    
    
}
