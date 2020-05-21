//
//  CalendarManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 9/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import EventKit

class CalendarManager {
    
    static let shared = CalendarManager()
    
    private init() {}
    
    let store = EKEventStore()
    
    func addEventToCalendar(view: UIViewController, with title: String, forDate eventStartDate: Date, location: String) {
        
        store.requestAccess(to: .event) { (success, error) in
            if error == nil {
                
                // Event Information
                let event = EKEvent.init(eventStore: self.store)
                event.title = title
                event.calendar = self.store.defaultCalendarForNewEvents
                event.startDate = eventStartDate
                event.endDate = Calendar.current.date(byAdding: .minute, value: 60, to: eventStartDate)
                event.location = location
                
                let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -3600, since: event.startDate))
                event.addAlarm(alarm)
                
                let predicate = self.store.predicateForEvents(withStart: eventStartDate,
                                                              end: Calendar.current.date(byAdding: .minute, value: 60, to: eventStartDate)! ,
                                                              calendars: nil)
                let existingEvents = self.store.events(matching: predicate)
                let eventAlreadyAdded = existingEvents.contains { (existingEvent) -> Bool in
                    existingEvent.title == title && existingEvent.startDate == eventStartDate
                }
                
                if eventAlreadyAdded {
                    self.showEventAlreadyAddedAlert(view: view)
                    
                } else {
                    
                    do {
                        try self.store.save(event, span: .thisEvent)
                        
                        DispatchQueue.main.async {
                            self.showEventSucessfullySavedAlert(view: view)
                        }
                        
                    } catch let error {
                        print("failed to save event", error)
                    }
                }
            } else {
                print("error = \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    private func showEventAlreadyAddedAlert(view: UIViewController) {
        let alert = UIAlertController(title: "No updates",
                                      message: AlertStrings.eventExisted,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .default,
                                      handler: nil))
        
        DispatchQueue.main.async(execute: {
            view.present(alert, animated: true)
        })
    }
    
    private func showEventSucessfullySavedAlert(view: UIViewController) {
        let doneAlert = UIAlertController(title: "Success",
                                          message: AlertStrings.calendarAlert,
                                          preferredStyle: .alert)
        doneAlert.addAction(UIAlertAction(title: "Done",
                                          style: .default,
                                          handler: nil))
        view.present(doneAlert, animated: true, completion: nil)
    }
    
}
