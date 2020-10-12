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
    
    private let tasksChild = Database.database().reference()
        .child(Event.shared.hostIdentifier)
        .child(DataKeys.events)
        .child(Event.shared.firebaseEventUid)
        .child(DataKeys.tasks)
        
    let tasks : MutableProperty<[Task]>
    let servings : MutableProperty<Int>
    var classifiedTasks = [[Task]]()
    var expandableTasks = [ExpandableTasks]()
    let sectionNames = MutableProperty<[String]>([])
    
    let isLoading = MutableProperty<Bool>(false)
    
    var isSending = false
    
    var pendingTasks = [Task]()
    var tasksToUpdate = [Task]()
    
    let newDataSignal : Signal<Result<Void, LDError>, Never>
    private let newDataObserver : Signal<Result<Void, LDError>, Never>.Observer
    
    let onlineUsersSignal : Signal<Int, Never>
    private let onlineUsersObserver : Signal<Int, Never>.Observer
    
    let taskUpdateSignal : Signal<Void, Never>
    private let taskUpdateObserver : Signal<Void, Never>.Observer
    
    let taskUploadSignal : Signal<Result<Void, LDError>, Never>
    private let taskUploadObserver : Signal<Result<Void, LDError>, Never>.Observer
    
    var currentUserOnline = false
    
    init() {
        tasks = MutableProperty<[Task]>(Event.shared.tasks.sorted { $0.taskName < $1.taskName })
        servings = MutableProperty<Int>(Event.shared.servings)
        
        let (newDataSignal, newDataObserver) = Signal<Result<Void, LDError>, Never>.pipe()
        self.newDataSignal = newDataSignal
        self.newDataObserver = newDataObserver
        
        let (onlineUsersSignal, onlineUsersObserver) = Signal<Int, Never>.pipe()
        self.onlineUsersSignal = onlineUsersSignal
        self.onlineUsersObserver = onlineUsersObserver
        
        let (taskUpdateSignal, taskUpdateObserver) = Signal<Void, Never>.pipe()
        self.taskUpdateSignal = taskUpdateSignal
        self.taskUpdateObserver = taskUpdateObserver
        
        let (taskUploadSignal, taskUploadObserver) = Signal<Result<Void, LDError>, Never>.pipe()
        self.taskUploadSignal = taskUploadSignal
        self.taskUploadObserver = taskUploadObserver
        
        usersChild.observe(.value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            onlineUsersObserver.send(value: value)
        }
        
        tasksChild.observe(.childChanged) { _ in
            if !self.isSending {
                taskUpdateObserver.send(value: ())
            }
        }
        
        servings.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] servings in
                guard let self = self else { return }
                self.updateServings(servings: servings)
        }
        
        self.updateTasks()
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
        newDataObserver.send(value: .success(()))
    }
    
    func sortTasks() {
        tasks.value = tasks.value.sorted(by: { $0.taskState.rawValue < $1.taskState.rawValue } )
        prepareTasks()
    }
    
    func updateSummaryText() {
        let numberOfUpdatedTasks = Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()
        let taskString = numberOfUpdatedTasks == 1 ? LabelStrings.task : LabelStrings.tasks
        let summaryForServings = String.localizedStringWithFormat(LabelStrings.updatedServingsSummary, defaults.username)
        let summaryForTasks = String.localizedStringWithFormat(LabelStrings.updatedTasksSummary, defaults.username, numberOfUpdatedTasks, taskString)
        let summaryForTasksAndServings = String.localizedStringWithFormat(LabelStrings.updatedTasksAndServingsSummary, defaults.username, numberOfUpdatedTasks, taskString)
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
        guard !currentUserOnline else { return }
        getNumberOfOnlineUsers { number in
            let updatedOnlineUsers = number + 1
            self.usersChild.setValue(updatedOnlineUsers)
            self.currentUserOnline = true
        }
    }
    
    func removeOnlineUser() {
        getNumberOfOnlineUsers { number in
            let updatedOnlineUsers = number - 1
            self.usersChild.setValue(updatedOnlineUsers)
            self.currentUserOnline = false
        }
    }
    
    func stopObservingOnlineUsers() {
        self.usersChild.removeAllObservers()
    }
    
    func updateTasks() {
        self.pendingTasks = Event.shared.tasks
        Event.shared.fetchTasksAndServings()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.newDataObserver.send(value: .failure(error))
                case .success():
                    self.tasks.value = Event.shared.tasks.sorted { $0.taskName < $1.taskName }
                    self.servings.value = Event.shared.servings
                }
        }
    }
    
    func restoreTasks() {
        var newTasks = [Task]()
        Event.shared.currentConversationTaskStates.forEach { task in
            let newTask = Task(taskName: task.taskName,
                               assignedPersonUid: task.assignedPersonUid,
                               taskState: task.taskState.rawValue,
                               taskUid: task.taskUid,
                               assignedPersonName: task.assignedPersonName,
                               isCustom: task.isCustom,
                               parentRecipe: task.parentRecipe)
            if let amount = task.metricAmount,
                let unit = task.metricUnit {
                newTask.metricAmount = amount
                newTask.metricUnit = unit
            }
            newTasks.append(newTask)
        }
        Event.shared.tasks = newTasks
        self.prepareTasks()
    }
    
    func uploadUpdatedTasks() {
        Event.shared.updateFirebaseTasks()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.taskUploadObserver.send(value: .failure(error))
                case .success():
                    self.taskUploadObserver.send(value: .success(()))
                }
        }
    }
    
    func uploadUpdatedTasksAndServings() {
        Event.shared.updateFirebaseTasksAndServings()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.taskUploadObserver.send(value: .failure(error))
                case .success():
                    self.taskUploadObserver.send(value: .success(()))
                }
        }
    }
    
    func pendingChanges() -> Bool {
        let pendingAssignedTasks = self.pendingTasks.filter { $0.assignedPersonUid == Event.shared.currentUser?.identifier }
        let freeTasks = Event.shared.tasks.filter { $0.taskState == .unassigned }
        
        pendingAssignedTasks.forEach { pendingTask in
            if freeTasks.contains(where: { $0.taskUid == pendingTask.taskUid }) {
                tasksToUpdate.append(pendingTask)
            }
        }
        return !tasksToUpdate.isEmpty
    }
    
    func applyPendingChanges() {
        tasksToUpdate.forEach { taskUpdate in
            let index = Event.shared.tasks.firstIndex { $0.taskUid == taskUpdate.taskUid }
            if let index = index {
                Event.shared.tasks[index] = taskUpdate
            }
        }
        self.pendingTasks.removeAll()
        self.tasksToUpdate.removeAll()
        self.tasks.value = Event.shared.tasks.sorted { $0.taskName < $1.taskName }
        self.prepareTasks()
    }
}

