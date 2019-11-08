//
//  Task.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

extension Task: Equatable {
    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.taskState == rhs.taskState && lhs.taskUid == rhs.taskUid
    }
}
