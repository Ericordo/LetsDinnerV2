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
    
    let statusUpdateSignal: Signal<Invitation, LDError>
    private let statusUpdateObserver: Signal<Invitation, LDError>.Observer
    
    let dateUpdateSignal: Signal<Result<Void, LDError>, Never>
    private let dateUpdateObserver: Signal<Result<Void, LDError>, Never>.Observer
    
    init() {
        let (eventFetchSignal, eventFetchObserver) = Signal<Void, LDError>.pipe()
        self.eventFetchSignal = eventFetchSignal
        self.eventFetchObserver = eventFetchObserver
        
        let (statusUpdateSignal, statusUpdateObserver) = Signal<Invitation, LDError>.pipe()
        self.statusUpdateSignal = statusUpdateSignal
        self.statusUpdateObserver = statusUpdateObserver
        
        let (dateUpdateSignal, dateUpdateObserver) = Signal<Result<Void, LDError>, Never>.pipe()
        self.dateUpdateSignal = dateUpdateSignal
        self.dateUpdateObserver = dateUpdateObserver

        self.fetchEvent()
    }
    
    func fetchEvent() {
        Event.shared.observeEvent()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.eventFetchObserver.send(error: error)
                case .success():
                    self.eventFetchObserver.send(value: ())
                }
        }
    }
    
    func updateStatus(_ status: Invitation) {
        Event.shared.updateFirebaseStatus(status: status)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.statusUpdateObserver.send(error: error)
                case .success():
                    if status == .declined {
                        self.unassignTasksOfCurrentUser()
                    } else {
                        self.statusUpdateObserver.send(value: (status))
                    }
                }
        }
    }
    
    private func unassignTasksOfCurrentUser() {
        guard let currentUser = Event.shared.currentUser else { return }
        Event.shared.tasks.forEach { task in
            if currentUser.identifier == task.ownerId {
                task.state = .unassigned
                task.ownerName = "nil"
                task.ownerId = "nil"
            }
        }
        guard Event.shared.tasksNeedUpdate else {
            self.statusUpdateObserver.send(value: .declined)
            return
        }
        Event.shared.updateFirebaseTasks()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.statusUpdateObserver.send(error: error)
                case .success():
                    self.statusUpdateObserver.send(value: (.declined))
                }
        }
    }
    
    func rescheduleEvent(date: Double) {
        Event.shared.updateFirebaseDate(date)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.dateUpdateObserver.send(value: .failure(error))
                case .success():
                    self.dateUpdateObserver.send(value: .success(()))
                }
        }
    }
}
