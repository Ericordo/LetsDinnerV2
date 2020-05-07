//
//  UserDefaults.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

extension UserDefaults {
    var username: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }
    
    var profilePicUrl: String {
        get { return string(forKey: Keys.profilePicUrl) ?? "" }
        set { set(newValue, forKey: Keys.profilePicUrl) }
    }
    
    var address: String {
        get { return string(forKey: Keys.address) ?? "" }
        set { set(newValue, forKey: Keys.address) }
    }
    
    var measurementSystem: String {
        get { return string(forKey: Keys.measurementSystem) ?? "" }
        set { set(newValue, forKey: Keys.measurementSystem) }
    }
    
    var searchType: String {
        get { return string(forKey: Keys.searchType) ?? "" }
        set { set(newValue, forKey: Keys.searchType) }
    }
    
}
