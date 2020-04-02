//
//  MSConversation+Ext.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 01/04/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import Messages

extension MSConversation {
    
    var isSelectedMessageFromMe : Bool {
        return selectedMessage?.senderParticipantIdentifier == localParticipantIdentifier
    }

    
}
