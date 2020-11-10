//
//  IAPError.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 13/10/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

enum IAPError: Error {
    case noProductIDsFound
    case noProductsFound
    case paymentWasCancelled
    case productRequestFailed
    case paymentNotAvailable
    case purchaseFailed
    case secretNotFetched
    case receiptVerificationFail
    case restoreFailed
    case nothingToRestore
}

extension IAPError {
    var description : String {
        switch self {
        case .noProductIDsFound:
            return AlertStrings.noProductIDsFound
        case .noProductsFound:
            return AlertStrings.noProductsFound
        case .paymentWasCancelled:
            return AlertStrings.paymentWasCancelled
        case .productRequestFailed:
            return AlertStrings.productRequestFailed
        case .paymentNotAvailable:
            return AlertStrings.paymentNotAvailable
        case .purchaseFailed:
            return AlertStrings.purchaseFailed
        case .secretNotFetched:
            return AlertStrings.secretNotFetched
        case .receiptVerificationFail:
            return AlertStrings.receiptVerificationFail
        case .restoreFailed:
            return AlertStrings.restoreFailed
        case .nothingToRestore:
            return AlertStrings.nothingToRestore
        }
    }
}
