//
//  SendAction.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 30/03/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

enum SendAction {
    case createEvent
    case rescheduleEvent
    case cancelEvent
    case answerInvitation
    case updateTasks
    case none
}
