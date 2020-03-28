//
//  ReminderManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 9/1/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import EventKit
import UIKit

let reminderManager = ReminderManager.sharedInstance
private var _SingletonSharedInstance =  ReminderManager()

class ReminderManager {
    
    public class var sharedInstance : ReminderManager {
        return _SingletonSharedInstance
    }
    
    let reminderStore = EKEventStore()
    let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    
    func addToReminder(view: UIViewController) {
          
          // Get permission
        reminderStore.requestAccess(to: EKEntityType.reminder, completion: { granted, error in

            if !granted {
                print("Access to store not granted")
                
            } else if (granted) && (error == nil) {

                let calendars = self.reminderStore.calendars(for: .reminder)
                let bundleList: EKCalendar

                // Create List if if list not exist
                if let bundleCalendar = calendars.first(where: {$0.title == (self.bundleName + " - Things To Buy")}) {
                // If Exist
                    bundleList = bundleCalendar
                } else {
                    // Create List
                    do {
                        bundleList = try self.createNewList(bundleName: self.bundleName)
                    } catch {
                        print("Cannot create new list")
                        return
                    }
                }
                
                // Filter Assigned Tasks
                guard Event.shared.tasks.count != 0 else { return self.alertNoTask(view: view) }
                let assignedTask = self.filterAssignedTask()
                
                // Go ahead if Assignedtask is not nil
                guard assignedTask.count != 0 else {return self.alertNoTask(view: view) } // No Tasks, return alert

                // Delete Task if any
                self.deleteExistingTasks()
                
                // Export tasks
                let existingTasks = assignedTask.sorted { $0.taskName < $1.taskName } // TO BE EDIT
                existingTasks.forEach { task in
                    do {
                        try self.importTasksToReminders(bundleList: bundleList, task: task)
                    } catch {
                        print("cannot save task")
                        return
                    }
                }
                
                // Alert
                self.alertSuccessPopup(view: view)
                
            }
        })
    }
    
    func createNewList(bundleName: String) throws -> EKCalendar {
        let calendar = EKCalendar(for: .reminder, eventStore: self.reminderStore)
        calendar.title = bundleName + " - Things To Buy" // Dinner title
        calendar.source = self.reminderStore.defaultCalendarForNewReminders()?.source

        if #available(iOSApplicationExtension 13.0, *) {
            calendar.cgColor = .init(srgbRed: 255, green: 0, blue: 0, alpha: 1)
        }
        
        try self.reminderStore.saveCalendar(calendar, commit: true)
        return calendar
    }
    
    private func filterAssignedTask() -> [Task] {
        // Filter only Assigned and Incomplete Tasks
        var resultArray = [Task]()
        resultArray = Event.shared.tasks.filter { $0.assignedPersonUid == Event.shared.currentUser?.identifier && $0.taskState == .assigned}
        return resultArray
    }
    
    private func importTasksToReminders(bundleList: EKCalendar, task: Task) throws {
        let reminder: EKReminder = EKReminder(eventStore: self.reminderStore)
        
        if let amount = task.metricAmount, let unit = task.metricUnit {
            reminder.title = "\(task.taskName), \(String(format:"%.1f", amount)) \(unit)"
        } else if let amount = task.metricAmount {
            reminder.title = "\(task.taskName), \(String(format:"%.1f", amount))"
        } else {
            reminder.title = task.taskName
        }
        
        reminder.calendar = bundleList
        
        //        reminder.completionDate = Date()
        //                  reminder.priority = 2
        //                  reminder.notes = "...this is a note"
        //
        //                  let alarmTime = Date().addingTimeInterval(1*60*24*3)
        //                  let alarm = EKAlarm(absoluteDate: alarmTime)
        //                  reminder.addAlarm(alarm)
        
        try self.reminderStore.save(reminder, commit: true)
    }
    
    func deleteExistingTasks() {
        // If not nil, then clear ALL
        
        let predicate: NSPredicate? = reminderStore.predicateForReminders(in: nil)
        
        if let predicate = predicate {
            reminderStore.fetchReminders(matching: predicate) { foundReminders in
    
                guard let foundReminders = foundReminders else { return }
                
                let remindersToDelete = !foundReminders.isEmpty
                for reminder in foundReminders {
                    
                    // *** Remove only the lets dinner reminder *** Important
                    if reminder.calendar.title == self.bundleName + " - Things To Buy" {
                        do {
                            try self.reminderStore.remove(reminder, commit: false)
                        } catch {
                            print("cannot remove")
                            return
                        }
                    }
                    
                }
                
                if remindersToDelete {
                    do {
                        try self.reminderStore.commit()
                    } catch {
                        print("cannot commit")
                    }
                }
            }
        }
        
        
        /* predicateForRemindersInCalendars or
         predicateForIncompleteRemindersWithDueDateStarting:ending:calendars: or
         predicateForCompletedRemindersWithCompletionDateStarting:ending:calendars */
    }
    
    func alertSuccessPopup(view: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: MessagesToDisplay.addToRemindersTitle,
                                          message: MessagesToDisplay.addToRemindersMessage,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done",
                                          style: .default,
                                          handler: nil))
            view.present(alert, animated: true)
        }
    }
    
    func alertNoTask(view: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: MessagesToDisplay.remindersNoTaskTitle,
                                          message: MessagesToDisplay.remindersNoTaskMessage,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .default,
                                          handler: nil))
            view.present(alert, animated: true)
        }

    }
    
    
}
