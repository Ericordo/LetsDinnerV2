//
//  ReviewViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class ReviewViewModel {
    
    let isLoading = MutableProperty<Bool>(false)
    
    let addToCalendar : MutableProperty<Bool>
    
    let dataUploadSignal: Signal<Void, LDError>
    private let dataUploadObserver: Signal<Void, LDError>.Observer

    init() {
        addToCalendar = MutableProperty(defaults.addToCalendar)
        
        let (dataUploadSignal, dataUploadObserver) = Signal<Void, LDError>.pipe()
        self.dataUploadSignal = dataUploadSignal
        self.dataUploadObserver = dataUploadObserver
        
        addToCalendar.producer.startWithValues { value in
            defaults.addToCalendar = value
        }
    }
    
    func uploadEvent() {
        Event.shared.uploadEvent()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.dataUploadObserver.send(error: error)
                case .success():
                    if self.addToCalendar.value {
                        self.addEventToCalendar()
                    }
                    self.dataUploadObserver.send(value: ())
                }
        }
    }
    
    func addEventToCalendar() {
        let title = Event.shared.dinnerName
        let date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
        let location = Event.shared.dinnerLocation
        
        CalendarManager.shared.addNewEventToCalendar(title: title,
                                                     eventStartDate: date,
                                                     location: location)
    }
}
