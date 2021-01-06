//
//  SearchManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 02/01/2021.
//  Copyright © 2021 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift
import FirebaseDatabase

class SearchManager {
    
    static let shared = SearchManager()
    
    private init() {}
    
    private func retrieveSearchAllowed() -> SignalProducer<Bool, LDError> {
        return SignalProducer { observer, _ in
            Database.database().reference()
                .child(DataKeys.appInfo)
                .child(DataKeys.searchAllowed)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let searchAllowed = snapshot.value as? Bool else {
                        observer.send(error: .genericError)
                        return }
                    observer.send(value: searchAllowed)
                    observer.sendCompleted()
                }
        }
    }
    
    private func retrieveMaxSearches() -> SignalProducer<Int, LDError> {
        return SignalProducer { observer, _ in
            Database.database().reference()
                .child(DataKeys.appInfo)
                .child(DataKeys.maxSearches)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let maxSearches = snapshot.value as? Int else {
                        observer.send(error: .genericError)
                        return }
                    observer.send(value: maxSearches)
                    observer.sendCompleted()
                }
        }
    }
    
    func checkEligibility() -> SignalProducer<Bool, LDError> {
        return self.retrieveSearchAllowed().flatMap(.concat) { [weak self] searchAllowed -> SignalProducer<Bool, LDError> in
            guard let self = self else { return SignalProducer.init(error: LDError.genericError) }
            if searchAllowed {
                return self.retrieveMaxSearches().flatMap(.concat) { maxSearches -> SignalProducer<Bool, LDError> in
                    guard let currentNumberOfSearches = CloudManager.shared.retrieveUserSearchCountOnCloud() else {
                        return SignalProducer.init(value: true)
                    }
                    if Int(currentNumberOfSearches) < maxSearches {
                        return SignalProducer.init(value: true)
                    } else {
                        return SignalProducer.init(value: false)
                    }
                }
            } else {
                return SignalProducer.init(value: false)
            }
        }
    }
    
    func resetNumberOfSearchesIfNeeded() {
        guard let lastSearchDateTimestamp : Double = CloudManager.shared.retrieveUserLastSearchDate() else { return }
        if Date().timeIntervalSince1970 - lastSearchDateTimestamp > 86400 {
            CloudManager.shared.resetUserSearchCountOnCloud()
        }
    }
}
