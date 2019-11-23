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
        get { return string(forKey: "profilePicUrl") ?? "" }
        set { set(newValue, forKey: "profilePicUrl") }
    }
    
    var hasAccepted: String {
        get { return string(forKey: "hasAccepted") ?? ""}
        set { set(newValue, forKey: "hasAccepted")}
    }
}
