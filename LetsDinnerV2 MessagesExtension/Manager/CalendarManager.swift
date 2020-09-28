//
//  CalendarManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 9/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import EventKit
import ReactiveSwift

class CalendarManager {
    
    static let shared = CalendarManager()
    
    private init() {}
    
    private let store = EKEventStore()
    
    func addEventToCalendar(on viewController: UIViewController,
                            with title: String,
                            forDate eventStartDate: Date,
                            location: String) {
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
                                                      end: Calendar.current.date(byAdding: .minute,
                                                                                 value: 60,
                                                                                 to: eventStartDate)!,
                                                      calendars: nil)
        let existingEvents = self.store.events(matching: predicate)
        let eventAlreadyAdded = existingEvents.contains { (existingEvent) -> Bool in
            existingEvent.title == title && existingEvent.startDate == eventStartDate
        }
        
        if eventAlreadyAdded {
            DispatchQueue.main.async {
                self.showEventAlreadyAddedAlert(on: viewController)
            }
        } else {
            
            do {
                try self.store.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    self.showEventSucessfullySavedAlert(on: viewController)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    func addNewEventToCalendar(title: String, eventStartDate: Date, location: String) {
        let event = EKEvent.init(eventStore: self.store)
        event.title = title
        event.calendar = self.store.defaultCalendarForNewEvents
        event.startDate = eventStartDate
        event.endDate = Calendar.current.date(byAdding: .minute, value: 60, to: eventStartDate)
        event.location = location
        
        let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -3600, since: event.startDate))
        event.addAlarm(alarm)
        
        do {
            try self.store.save(event, span: .thisEvent)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func requestAccessToCalendarIfNeeded() -> SignalProducer<Bool, Never> {
        return SignalProducer { observer, _ in
            self.store.requestAccess(to: .event) { (approval, error) in
                if error != nil {
                    observer.send(value: false)
                } else {
                    observer.send(value: approval)
                }
                observer.sendCompleted()
            }
        }
    }

    private func showEventAlreadyAddedAlert(on viewController: UIViewController) {
        let alert = UIAlertController(title: AlertStrings.noNeed,
                                      message: AlertStrings.eventExisted,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AlertStrings.okAction,
                                      style: .default,
                                      handler: nil))
        viewController.present(alert, animated: true)
    }

    private func showEventSucessfullySavedAlert(on viewController: UIViewController) {
        let doneAlert = UIAlertController(title: AlertStrings.success,
                                          message: AlertStrings.calendarAlert,
                                          preferredStyle: .alert)
        doneAlert.addAction(UIAlertAction(title: AlertStrings.okAction,
                                          style: .default,
                                          handler: nil))
        viewController.present(doneAlert, animated: true, completion: nil)
    }
}
