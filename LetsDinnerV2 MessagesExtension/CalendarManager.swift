//
//  CalendarManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 9/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import EventKit

let calendarManager = CalendarManager.sharedInstance
private var _SingletonSharedInstance =  CalendarManager()

class CalendarManager {
    
    public class var sharedInstance : CalendarManager {
        return _SingletonSharedInstance
    }
    
    let store = EKEventStore()
    
    func addEventToCalendar(view: UIViewController, with title: String, forDate eventStartDate: Date, location: String) {
        
        store.requestAccess(to: .event) { (success, error) in
            if error == nil {
                let event = EKEvent.init(eventStore: self.store)
                event.title = title
                event.calendar = self.store.defaultCalendarForNewEvents
                event.startDate = eventStartDate
                event.endDate = Calendar.current.date(byAdding: .minute, value: 60, to: eventStartDate)
                event.location = location
                
                let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -3600, since: event.startDate))
                event.addAlarm(alarm)
                
                let predicate = self.store.predicateForEvents(withStart: eventStartDate, end: Calendar.current.date(byAdding: .minute, value: 60, to: eventStartDate)! , calendars: nil)
                let existingEvents = self.store.events(matching: predicate)
                let eventAlreadyAdded = existingEvents.contains { (existingEvent) -> Bool in
                    existingEvent.title == title && existingEvent.startDate == eventStartDate
                }
                
                if eventAlreadyAdded {
                    let alert = UIAlertController(title: MessagesToDisplay.eventExists,
                                                  message: "",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: .default,
                                                  handler: nil))
                    
                    DispatchQueue.main.async(execute: {
                        view.present(alert, animated: true)
                    })
                } else {

                    do {
                        try self.store.save(event, span: .thisEvent)
                        DispatchQueue.main.async {
                            let doneAlert = UIAlertController(title: MessagesToDisplay.calendarAlert,
                                                              message: "",
                                                              preferredStyle: .alert)
                            doneAlert.addAction(UIAlertAction(title: "OK",
                                                              style: .default,
                                                              handler: nil))
                            view.present(doneAlert, animated: true, completion: nil)
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
    
}