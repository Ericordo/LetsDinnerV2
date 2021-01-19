//
//  Task.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

enum TaskState: Int, Codable {
    case unassigned = 0
    case assigned = 1
    case completed = 2
}

class Task: Hashable, Codable, Equatable {
    var id : String
    var name: String
    var ownerName: String
    var ownerId: String?
    var state: TaskState
    var isCustom: Bool
    var parentRecipe: String
    var amount: Double?
    var unit: String?
    var servings: Int?
    
//    var hashValue: Int {
//        return taskUid.hashValue
//    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.state == rhs.state && lhs.id == rhs.id
    }
    
    init(id: String = UUID().uuidString, name: String, ownerName: String, ownerId: String?, state: TaskState, isCustom: Bool, parentRecipe: String) {
        self.id = id
        self.name = name
        self.ownerName = ownerName
        self.ownerId = ownerId
        self.state = state
        self.isCustom = isCustom
        self.parentRecipe = parentRecipe
    }
}


