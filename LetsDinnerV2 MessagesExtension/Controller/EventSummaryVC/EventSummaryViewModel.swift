//
//  EventSummaryViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 17/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class EventSummaryViewModel {
    
    let isLoading = MutableProperty<Bool>(false)
    
    let eventFetchSignal: Signal<Void, LDError>
    private let eventFetchObserver: Signal<Void, LDError>.Observer
    
    init() {
        let (eventFetchSignal, eventFetchObserver) = Signal<Void, LDError>.pipe()
        self.eventFetchSignal = eventFetchSignal
        self.eventFetchObserver = eventFetchObserver

        self.fetchEvent()
    }
    
    func fetchEvent() {
        Event.shared.observeEvent()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .observe(on: UIScheduler())
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.eventFetchObserver.send(error: error)
                case .success():
                    self.eventFetchObserver.send(value: ())
                }
        }
    }
    
}
