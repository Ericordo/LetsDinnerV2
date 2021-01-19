//
//  ManagementViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 12/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class ManagementViewModel {
    
    let tasks : MutableProperty<[Task]>
    let servings : MutableProperty<Int>
    var classifiedTasks = [[Task]]()
    var expandableTasks = [ExpandableTasks]()
    let sectionNames = MutableProperty<[String]>([])
    
    let newDataSignal : Signal<Void, Never>
    private let newDataObserver : Signal<Void, Never>.Observer
    
    init() {
        tasks = MutableProperty<[Task]>(Event.shared.tasks)
        servings = MutableProperty<Int>(Event.shared.servings)
        
        let (newDataSignal, newDataObserver) = Signal<Void, Never>.pipe()
        self.newDataSignal = newDataSignal
        self.newDataObserver = newDataObserver
        
        servings.producer.observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] servings in
                guard let self = self else { return }
                self.updateServings(servings: servings)
        }
    }
    
    private func updateServings(servings: Int) {
        Event.shared.tasks.forEach { task in
            if !task.isCustom {
                if let amount = task.amount, let oldServings = task.servings {
                    task.amount = (amount * Double(servings)) / Double(oldServings)
                    task.servings = servings
                }
            }
        }
        prepareData()
    }
    
    func prepareData() {
        tasks.value = Event.shared.tasks
        classifiedTasks.removeAll()
        
        var expandedStatus = [String : Bool]()
        
        expandableTasks.forEach { expandableTasks in
            if let parentRecipe = expandableTasks.tasks.first?.parentRecipe {
                expandedStatus[parentRecipe] = expandableTasks.isExpanded
            }
        }
        
        expandableTasks.removeAll()
        sectionNames.value.removeAll()
        
        // Append the task into classified Task
        tasks.value.forEach { task in
            if classifiedTasks.contains(where: { subTasks -> Bool in
                subTasks.contains { (individualTask) -> Bool in
                    individualTask.parentRecipe == task.parentRecipe}
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

        // Append Expandable Tasks
        classifiedTasks.forEach { subtasks in
            var subExpandableTasks = ExpandableTasks(isExpanded: true, tasks: subtasks)
            if let parentRecipe = subtasks.first?.parentRecipe {
                if let isExpanded = expandedStatus[parentRecipe] {
                    subExpandableTasks = ExpandableTasks(isExpanded: isExpanded, tasks: subtasks)
                }
            }
            expandableTasks.append(subExpandableTasks)
            if let sectionName = subtasks.first?.parentRecipe {
                sectionNames.value.append(sectionName)
            }
        }
        expandedStatus.removeAll()
        newDataObserver.send(value: ())
    }
}
