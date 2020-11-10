//
//  PremiumCheckViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/11/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift
//import StoreKit
//import SwiftyStoreKit

// Ways to access new event:
// from InitialVC
// from IdleVC
// from ExpiredEventVC
// from RegistrationVC

class PremiumCheckViewModel {
    
    let subscribedSignal : Signal<Result<Void, IAPError>, Never>
    private let subscribedObserver : Signal<Result<Void, IAPError>, Never>.Observer
    
    let newSubscriptionSignal : Signal<Result<NewSubscription, IAPError>, Never>
    private let newSubscriptionObserver : Signal<Result<NewSubscription, IAPError>, Never>.Observer

    let isLoading = MutableProperty<Bool>(false)
    
    init() {
        let (subscribedSignal, subscribedObserver) = Signal<Result<Void, IAPError>, Never>.pipe()
        self.subscribedSignal = subscribedSignal
        self.subscribedObserver = subscribedObserver
        
        let (newSubscriptionSignal, newSubscriptionObserver) = Signal<Result<NewSubscription, IAPError>, Never>.pipe()
        self.newSubscriptionSignal = newSubscriptionSignal
        self.newSubscriptionObserver = newSubscriptionObserver
    }
    
    func checkIfUserIsSubscribed() {
        IAPHelper.shared.verifyCurrentSubscription()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.subscribedObserver.send(value: .failure(error))
                case .success(let status):
                    switch status {
                    case .expired:
                        self.getSubscriptionProduct(isTrialEligible: false)
                    case .purchased:
                        self.subscribedObserver.send(value: .success(()))
                    case .notPurchased:
                        self.getSubscriptionProduct(isTrialEligible: true)
                    }
                }
        }
    }
    
    func getSubscriptionProduct(isTrialEligible: Bool) {
            self.isLoading.value = true
            IAPHelper.shared.getProducts { [weak self] result in
                guard let self = self else { return }
                self.isLoading.value = false
                switch result {
                case .failure(let error):
                    self.newSubscriptionObserver.send(value: .failure(error))
                case .success(let products):
                    if let product = products.first,
                       product.productIdentifier == IAPProduct.proSubscription.rawValue {
                        self.newSubscriptionObserver.send(value: .success(NewSubscription(product: product,
                                                                                          isTrialEligible: isTrialEligible)))
                    } else {
                        self.newSubscriptionObserver.send(value: .failure(.noProductsFound))
                    }
                }
            }
        }
}
