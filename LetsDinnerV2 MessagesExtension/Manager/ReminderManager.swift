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
    
    func addToReminder(view: UIViewController) {
          
          // Get permission
        reminderStore.requestAccess(to: EKEntityType.reminder, completion: { granted, error in

            if !granted {
                print("Access to store not granted")
                
            } else if (granted) && (error == nil) {

                let calendars = self.reminderStore.calendars(for: .reminder)
                let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
                let bundleList: EKCalendar

                // Create List if if list not exist
                if let bundleCalendar = calendars.first(where: {$0.title == bundleName}) {
                // If Exist
                    bundleList = bundleCalendar
                } else {
                    // Create List
                    do {
                        bundleList = try self.createNewList(bundleName: bundleName)
                    } catch {
                        print("Cannot create new list")
                        return
                    }
                }
                
                // Go ahead if task is not nil
                guard Event.shared.tasks.count != 0 else { return } // No Tasks, return alert

                // Delete Task if any
                self.deleteExistingTasks()
                
                // Export tasks
                let existingTasks = Event.shared.tasks.sorted { $0.taskName < $1.taskName }
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
        calendar.title = bundleName // Dinner title
        calendar.source = self.reminderStore.defaultCalendarForNewReminders()?.source

        if #available(iOSApplicationExtension 13.0, *) {
            calendar.cgColor = .init(srgbRed: 255, green: 0, blue: 0, alpha: 1)
        }
        
        try self.reminderStore.saveCalendar(calendar, commit: true)
        return calendar
    }
    
    func importTasksToReminders(bundleList: EKCalendar, task: Task) throws {
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
                    do {
                        try self.reminderStore.remove(reminder, commit: false)
                    } catch {
                        print("cannot remove")
                        return
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
        let alert = UIAlertController(title: MessagesToDisplay.addToRemindersMessage,
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done",
                                      style: .default,
                                      handler: nil))
        
        DispatchQueue.main.async(execute: {
            view.present(alert, animated: true)
        })
    }
    
    
}
