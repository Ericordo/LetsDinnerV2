//
//  PremiumViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 13/10/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift
import StoreKit

class PremiumViewModel {

    let newSubscription : NewSubscription

    let subscriptionSignal : Signal<Result<Void, IAPError>, Never>
    private let subscriptionObserver : Signal<Result<Void, IAPError>, Never>.Observer
    
    let productSignal : Signal<Result<SKProduct, IAPError>, Never>
    private let productObserver : Signal<Result<SKProduct, IAPError>, Never>.Observer
    
    let restoreSignal : Signal<Result<Bool, IAPError>, Never>
    private let restoreObserver : Signal<Result<Bool, IAPError>, Never>.Observer
    
    let isLoading = MutableProperty<Bool>(false)

    init(with newSubscription: NewSubscription) {
        self.newSubscription = newSubscription

        let (subscriptionSignal, subscriptionObserver) = Signal<Result<Void, IAPError>, Never>.pipe()
        self.subscriptionSignal = subscriptionSignal
        self.subscriptionObserver = subscriptionObserver
        
        let (productSignal, productObserver) = Signal<Result<SKProduct, IAPError>, Never>.pipe()
        self.productSignal = productSignal
        self.productObserver = productObserver
        
        let (restoreSignal, restoreObserver) = Signal<Result<Bool, IAPError>, Never>.pipe()
        self.restoreSignal = restoreSignal
        self.restoreObserver = restoreObserver
    }
        
    func subscribe() {
        self.isLoading.value = true
        IAPHelper.shared.buy(product: newSubscription.product) { [weak self] result in
            guard let self = self else { return }
            self.isLoading.value = false
            switch result {
            case .success(let success):
                if success {
                    self.subscriptionObserver.send(value: .success(()))
                } else {
                    self.subscriptionObserver.send(value: .failure(.purchaseFailed))
                }
            case .failure(let error):
                if let iapError = error as? IAPError {
                    self.subscriptionObserver.send(value: .failure(iapError))
                } else {
                    self.subscriptionObserver.send(value: .failure(.purchaseFailed))
                }
            }
        }
    }
    
    func restorePurchase() {
        self.isLoading.value = true
        IAPHelper.shared.restorePurchases { [weak self] result in
            guard let self = self else { return }
            self.isLoading.value = false
            switch result {
            case .failure(let error):
                if let iapError = error as? IAPError {
                    self.restoreObserver.send(value: .failure(iapError))
                } else {
                    self.restoreObserver.send(value: .failure(.restoreFailed))
                }
            case .success(let restored):
                if restored {
                    self.checkIfUserIsSubscribed()
                } else {
                    self.restoreObserver.send(value: .success(restored))
                }
            }
        }
    }
    
    private func checkIfUserIsSubscribed() {
        IAPHelper.shared.verifyCurrentSubscription()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.restoreObserver.send(value: .failure(error))
                case .success(let status):
                    switch status {
                    case .expired, .notPurchased:
                        self.restoreObserver.send(value: .failure(.nothingToRestore))
                    case .purchased:
                        self.restoreObserver.send(value: .success(true))
                    }
                }
        }
    }
}
