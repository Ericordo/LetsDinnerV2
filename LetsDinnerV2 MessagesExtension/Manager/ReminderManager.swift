//
//  ReminderManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 9/1/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import EventKit
import UIKit
import ReactiveSwift

class ReminderManager {

    static let shared = ReminderManager()
    
    private init() {}
    
    private let reminderStore = EKEventStore()
    
    private let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    
    private let listTitle = Event.shared.dinnerName + " - \(LabelStrings.thingsToBring)"
    
    func addToReminder(on viewController: UIViewController) {
        let calendars = self.reminderStore.calendars(for: .reminder)
        let bundleList: EKCalendar
        
        // Create List if list not exist
        if let bundleCalendar = calendars.first(where: { $0.title == listTitle }) {
            // If Exist
            bundleList = bundleCalendar
        } else {
            // Create List
            do {
                bundleList = try self.createNewList(bundleName: self.bundleName)
            } catch let error {
                #if DEBUG
                print(error.localizedDescription)
                #endif
                return
            }
        }
        
        // Filter Assigned Tasks
        guard Event.shared.tasks.count != 0 else { return self.showAlertNoTask(on: viewController) }
        let assignedTask = self.filterAssignedTasks()
        
        // Go ahead if Assignedtask is not nil
        guard assignedTask.count != 0 else { return self.showAlertNoTask(on: viewController) } // No Tasks, return alert
        
        // Delete Task if any
        self.deleteExistingTasks()
        
        // Export tasks
        let existingTasks = assignedTask.sorted { $0.name < $1.name } // TO BE EDIT
        existingTasks.forEach { task in
            do {
                try self.importTasksToReminders(bundleList: bundleList, task: task)
            } catch let error {
                #if DEBUG
                print(error.localizedDescription)
                #endif
                return
            }
        }
        
        // Alert
        self.showAlertSuccessPopup(on: viewController)
    }
    
    func requestAccessToRemindersIfNeeded() -> SignalProducer<Bool, Never> {
        return SignalProducer { observer, _ in
            self.reminderStore.requestAccess(to: EKEntityType.reminder) { (approval, error) in
                if error != nil {
                    observer.send(value: false)
                } else {
                    observer.send(value: approval)
                }
                observer.sendCompleted()
            }
        }
    }
    
    private func createNewList(bundleName: String) throws -> EKCalendar {
        let calendar = EKCalendar(for: .reminder,
                                  eventStore: self.reminderStore)
        calendar.title = listTitle // Dinner title
        calendar.source = self.reminderStore.defaultCalendarForNewReminders()?.source
        if #available(iOSApplicationExtension 13.0, *) {
            calendar.cgColor = .init(srgbRed: 255, green: 0, blue: 0, alpha: 1)
        }
        do {
            try self.reminderStore.saveCalendar(calendar, commit: true)
        } catch let error {
            #if DEBUG
            print(error.localizedDescription)
            #endif
        }
        return calendar
    }
    
    private func filterAssignedTasks() -> [Task] {
        // Filter only Assigned and Incomplete Tasks
        return Event.shared.tasks.filter { $0.ownerId == Event.shared.currentUser?.identifier && $0.state == .assigned }
    }
    
    private func importTasksToReminders(bundleList: EKCalendar, task: Task) throws {
        let reminder: EKReminder = EKReminder(eventStore: self.reminderStore)
        
        if let amount = task.amount, let unit = task.unit {
            reminder.title = "\(task.name), \(String(format:"%.1f", amount)) \(unit)"
        } else if let amount = task.amount {
            reminder.title = "\(task.name), \(String(format:"%.1f", amount))"
        } else {
            reminder.title = task.name
        }
        
        reminder.calendar = bundleList
        
        try self.reminderStore.save(reminder, commit: true)
    }
    
    private func deleteExistingTasks() {
        // If not nil, then clear all
        let predicate: NSPredicate? = reminderStore.predicateForReminders(in: nil)
        
        if let predicate = predicate {
            reminderStore.fetchReminders(matching: predicate) { foundReminders in
                
                guard let foundReminders = foundReminders else { return }
                
                for reminder in foundReminders {
                    
                    // *** Remove only the lets dinner reminder *** Important
                    if reminder.calendar.title == self.listTitle {
                        do {
                            try self.reminderStore.remove(reminder, commit: false)
                        } catch let error {
                            #if DEBUG
                            print(error.localizedDescription)
                            #endif
                            return
                        }
                    }
                }
                
                if !foundReminders.isEmpty {
                    do {
                        try self.reminderStore.commit()
                    } catch let error {
                        #if DEBUG
                        print(error.localizedDescription)
                        #endif
                    }
                }
            }
        }
    }
    
    private func showAlertSuccessPopup(on viewController: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: AlertStrings.success,
                                          message: AlertStrings.addToRemindersMessage,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: AlertStrings.okAction,
                                          style: .default,
                                          handler: nil))
            viewController.present(alert, animated: true)
        }
    }
    
    private func showAlertNoTask(on viewController: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: AlertStrings.remindersNoTaskTitle,
                                          message: AlertStrings.remindersNoTaskMessage,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: AlertStrings.okAction,
                                          style: .default,
                                          handler: nil))
            viewController.present(alert, animated: true)
        }
    }
}
