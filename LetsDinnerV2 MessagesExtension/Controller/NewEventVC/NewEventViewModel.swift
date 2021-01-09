//
//  NewEventViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 10/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class NewEventViewModel {
    
    let eventName : MutableProperty<String>
    let host: MutableProperty<String>
    let location: MutableProperty<String>
    let dateString: MutableProperty<String>
    let date: MutableProperty<Date>
    
    let infoValidity: MutableProperty<Bool>
    
    let dateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter
    }()
    
    let isLoading = MutableProperty<Bool>(false)
    
    let nextStepSignal: Signal<Result<Void, LDError>, Never>
    private let nextStepObserver: Signal<Result<Void, LDError>, Never>.Observer
    
    private let realmHelper = RealmHelper.shared
    private let cloudManager = CloudManager.shared
 
    init() {
        eventName = MutableProperty(Event.shared.dinnerName)
        host = MutableProperty(Event.shared.hostName)
        location = MutableProperty(Event.shared.dinnerLocation)
        dateString = MutableProperty(Event.shared.dinnerDate)
        date = MutableProperty(Date(timeIntervalSince1970: Event.shared.dateTimestamp))
        infoValidity = MutableProperty(false)
        
        let (nextStepSignal, nextStepObserver) = Signal<Result<Void, LDError>, Never>.pipe()
        self.nextStepSignal = nextStepSignal
        self.nextStepObserver = nextStepObserver
        
        eventName.producer.startWithValues { string in
            Event.shared.dinnerName = string
            self.validateInfo()
        }
        
        host.producer.startWithValues { string in
            Event.shared.hostName = string
            self.validateInfo()
        }
        
        location.producer.startWithValues { string in
            Event.shared.dinnerLocation = string
            self.validateInfo()
        }
        
        date.producer
            .filter({ $0.timeIntervalSince1970 != 0 })
            .startWithValues { date in
            self.dateString.value = self.dateFormatter.string(from: date)
                Event.shared.dateTimestamp = date.timeIntervalSince1970
                self.validateInfo()
        }
        
        dateString.producer.startWithValues { string in
            self.validateInfo()
        }
    }
        
    func validateInfo() {
        if self.eventName.value.isEmpty ||
            self.host.value.isEmpty ||
            self.location.value.isEmpty ||
            self.dateString.value.isEmpty {
            infoValidity.value = false
        } else {
            infoValidity.value = true
        }
    }
    
    func loadCustomRecipes() {
        self.customRecipesLoadingFlow()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.nextStepObserver.send(value: .failure(error))
                case .success():
                    self.nextStepObserver.send(value: .success(()))
                }
            }
    }
    
    private func customRecipesLoadingFlow() -> SignalProducer<Void, LDError> {
        return self.cloudManager.userIsLoggedIn()
            .flatMap(.concat) { [weak self] userIsLoggedIn -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                guard userIsLoggedIn else { return SignalProducer(error: .notSignedInCloud) }
                return self.cloudManager.fetchLDRecipesFromCloud()
            .flatMap(.concat) { [weak self] recipes -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                return self.realmHelper.transferCloudRecipesToRealm(recipes)
            }
        }
    }
}
