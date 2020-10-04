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

class Task: Hashable, Codable {
    var taskUid: String
    var taskName: String
    var assignedPersonName: String
    var assignedPersonUid: String?
    var taskState: TaskState
    
// MARK: Add for the custom tasks
    var isCustom: Bool
    
// MARK: Add for the collapse rows
    var parentRecipe: String
    
    // To change everywhere to var amount and var unit, as the selection is done before
    var metricAmount: Double?
    var metricUnit: String?

    var servings: Int?
    
//    var hashValue: Int {
//        return taskUid.hashValue
//    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(taskUid)
    }
    
    init(taskName: String, assignedPersonUid: String?, taskState: Int, taskUid: String, assignedPersonName: String, isCustom: Bool, parentRecipe: String) {
        self.taskName = taskName
        self.assignedPersonName = assignedPersonName
        self.taskState = TaskState(rawValue: taskState)!
        self.taskUid = taskUid
        self.assignedPersonUid = assignedPersonUid
        self.isCustom = isCustom
        self.parentRecipe = parentRecipe
    }
    
    
}


