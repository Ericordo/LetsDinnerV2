//
//  Task.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

class Task: Hashable {
    var taskUid: String
    var taskName: String
    var assignedPersonName: String
    var assignedPersonUid: String?
    var taskState: TaskState
    
// MARK: Add for the custom tasks
    var isCustom = false
    
// MARK: Add for the collapse rows

    var parentRecipe: String?
    
//    var hashValue: Int {
//        return taskUid.hashValue
//    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(taskUid)
    }
    
    init(taskName: String, assignedPersonUid: String?, taskState: Int, taskUid: String, assignedPersonName: String, parentRecipe: String?) {
        self.taskName = taskName
        self.assignedPersonName = assignedPersonName
        self.taskState = TaskState(rawValue: taskState)!
        self.taskUid = taskUid
        self.assignedPersonUid = assignedPersonUid
        
        self.parentRecipe = parentRecipe
    }
    
    
}

enum TaskState: Int {
    case unassigned = 0
    case assigned = 1
    case completed = 2
}
