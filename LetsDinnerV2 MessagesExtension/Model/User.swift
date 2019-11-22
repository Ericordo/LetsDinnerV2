//
//  User.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

class User {
    var identifier: String
    var fullName: String
    var hasAccepted: Invitation
    var profilePicUrl: String? 
    
    init(identifier: String, fullName: String, hasAccepted: Invitation) {
        self.identifier = identifier
        self.fullName = fullName
        self.hasAccepted = hasAccepted
    }
}

enum Invitation: String {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
}
