//
//  TasksListViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 19/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift
import FirebaseDatabase

class TasksListViewModel {
    
    private let usersChild = Database.database().reference()
        .child(Event.shared.hostIdentifier)
        .child(DataKeys.events)
        .child(Event.shared.firebaseEventUid)
        .child(DataKeys.onlineUsers)
    
    let tasks : MutableProperty<[Task]>
    let servings : MutableProperty<Int>
    var classifiedTasks = [[Task]]()
    var expandableTasks = [ExpandableTasks]()
    let sectionNames = MutableProperty<[String]>([])
    
    let newDataSignal : Signal<Void, Never>
    private let newDataObserver : Signal<Void, Never>.Observer
    
    let onlineUsersSignal : Signal<Int, Never>
    private let onlineUsersObserver : Signal<Int, Never>.Observer
    
    init() {
        tasks = MutableProperty<[Task]>(Event.shared.tasks.sorted { $0.taskName < $1.taskName })
        servings = MutableProperty<Int>(Event.shared.servings)
        
        let (newDataSignal, newDataObserver) = Signal<Void, Never>.pipe()
        self.newDataSignal = newDataSignal
        self.newDataObserver = newDataObserver
        
        let (onlineUsersSignal, onlineUsersObserver) = Signal<Int, Never>.pipe()
        self.onlineUsersSignal = onlineUsersSignal
        self.onlineUsersObserver = onlineUsersObserver
        
        usersChild.observe(.value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            onlineUsersObserver.send(value: value)
        }
        
        servings.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] servings in
                guard let self = self else { return }
                self.updateServings(servings: servings)
        }
    }
    
    private func updateServings(servings: Int) {
        let oldServings = Event.shared.servings
        Event.shared.servings = servings
        Event.shared.tasks.forEach { task in
            if !task.isCustom {
                if let amount = task.metricAmount {
                    task.metricAmount = (amount * Double(servings)) / Double(oldServings)
                    task.servings = servings
                }
            }
        }
        prepareTasks()
        updateSummaryText()
    }
    
    func prepareTasks() {
        classifiedTasks.removeAll()
        expandableTasks.removeAll()
        sectionNames.value.removeAll()
        
        tasks.value.forEach { task in
            if classifiedTasks.contains(where: { subTasks -> Bool in
                subTasks.contains { (individualTask) -> Bool in
                    individualTask.parentRecipe == task.parentRecipe
                }
            }) {
                let index = classifiedTasks.firstIndex { (subTasks) -> Bool in
                    subTasks.contains { (individualTask) -> Bool in
                        individualTask.parentRecipe == task.parentRecipe
                    }
                }
                classifiedTasks[index!].append(task)
            } else {
                classifiedTasks.append([task])
            }
        }
        classifiedTasks.forEach { subtasks in
            let subExpandableTasks = ExpandableTasks(isExpanded: true, tasks: subtasks)
            expandableTasks.append(subExpandableTasks)
            if let sectionName = subtasks.first?.parentRecipe {
                sectionNames.value.append(sectionName)
            }
        }
        newDataObserver.send(value: ())
    }
    
    func sortTasks() {
        tasks.value = tasks.value.sorted(by: { $0.taskState.rawValue < $1.taskState.rawValue } )
        prepareTasks()
    }
    
    func updateSummaryText() {
        #warning("localize")
        let numberOfUpdatedTasks = Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()
        let taskString = numberOfUpdatedTasks == 1 ? "task" : "tasks"
        let summaryForServings = "\(defaults.username) updated the servings!"
        let summaryForTasks = "\(defaults.username) updated \(numberOfUpdatedTasks) \(taskString)."
        let summaryForTasksAndServings = "\(defaults.username) updated \(numberOfUpdatedTasks) \(taskString) and the servings!"
        let tasksUpdate = Event.shared.tasksNeedUpdate
        let servingsUpdate = Event.shared.servingsNeedUpdate
        if tasksUpdate && servingsUpdate {
            Event.shared.summary = summaryForTasksAndServings
        } else if tasksUpdate && !servingsUpdate {
            Event.shared.summary = summaryForTasks
        } else if !tasksUpdate && servingsUpdate {
            Event.shared.summary = summaryForServings
        }
    }
    
    private func getNumberOfOnlineUsers(completion: @escaping (Int) -> Void) {
        usersChild.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            completion(value)
        }
    }
    
    func addOnlineUser() {
        getNumberOfOnlineUsers { number in
            let updatedOnlineUsers = number + 1
            self.usersChild.setValue(updatedOnlineUsers)
        }
    }
    
    func removeOnlineUser() {
        getNumberOfOnlineUsers { number in
            let updatedOnlineUsers = number - 1
            self.usersChild.setValue(updatedOnlineUsers)
        }
    }
}
