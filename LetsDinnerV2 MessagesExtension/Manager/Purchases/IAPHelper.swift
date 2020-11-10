//
//  IAPHelper.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 13/10/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import StoreKit
import FirebaseDatabase
import SwiftyStoreKit
import ReactiveSwift

class IAPHelper: NSObject {
    
    static let shared = IAPHelper()
    
    private override init() {}
    
    var onReceiveProductsHandler: ((Result<[SKProduct], IAPError>) -> Void)?
    
    var onBuyProductHandler: ((Result<Bool, Error>) -> Void)?
    
    var totalRestoredPurchases = 0
    
    private func getProductIDs() -> [String]? {
        guard let url = Bundle.main.url(forResource: "IAPProduct_IDs", withExtension: "plist") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            return nil
        }
    }
    
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler
        // Get the product identifiers.
        guard let productIDs = getProductIDs() else {
            productsReceiveHandler(.failure(.noProductIDsFound))
            return
        }
        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        // Set self as the its delegate.
        request.delegate = self
        // Make the request.
        request.start()
    }
    
//    func getPriceFormatted(for product: SKProduct) -> String? {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = product.priceLocale
//        return formatter.string(from: product.price)
//    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }

    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        // Keep the completion handler.
        onBuyProductHandler = handler
    }
    
    func restorePurchases(withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        onBuyProductHandler = handler
        totalRestoredPurchases = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
        let products = response.products
        DispatchQueue.main.async {
            // Check if there are any products available.
            if products.count > 0 {
                // Call the following handler passing the received products.
                self.onReceiveProductsHandler?(.success(products))
            } else {
                // No products were found.
                self.onReceiveProductsHandler?(.failure(.noProductsFound))
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
    
    func requestDidFinish(_ request: SKRequest) {
        // Implement this method OPTIONALLY and add any custom logic
        // you want to apply when a product request is finished.
    }
}

extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                onBuyProductHandler?(.success(true))
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                totalRestoredPurchases += 1
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler?(.failure(error))
                    } else {
                        onBuyProductHandler?(.failure(IAPError.paymentWasCancelled))
                    }
                    print("IAP Error:", error.localizedDescription)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if totalRestoredPurchases != 0 {
            onBuyProductHandler?(.success(true))
        } else {
            print("IAP: No purchases to restore!")
            onBuyProductHandler?(.success(false))
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                print("IAP Restore Error:", error.localizedDescription)
                onBuyProductHandler?(.failure(error))
            } else {
                onBuyProductHandler?(.failure(IAPError.paymentWasCancelled))
            }
        }
    }
}

extension IAPHelper {
    private func retrieveSharedSecret() -> SignalProducer<String, IAPError> {
        return SignalProducer { observer, _ in
            Database.database().reference()
                .child(DataKeys.appInfo)
                .child(DataKeys.sharedSecret)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let sharedSecret = snapshot.value as? String else {
                        observer.send(error: .secretNotFetched)
                        return }
                    observer.send(value: sharedSecret)
                    observer.sendCompleted()
                }
        }
    }

    private func verifyReceipt(productId: String, sharedSecret: String) -> SignalProducer<VerifySubscriptionResult, IAPError> {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        return SignalProducer { observer, _ in
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt)
                    switch purchaseResult {
                    case .purchased(let expiryDate, let items):
                        observer.send(value: .purchased(expiryDate: expiryDate, items: items))
                        print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    case .expired(let expiryDate, let items):
                        observer.send(value: .expired(expiryDate: expiryDate, items: items))
                        print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    case .notPurchased:
                        observer.send(value: .notPurchased)
                        print("The user has never purchased \(productId)")
                    }
                    observer.sendCompleted()
                case .error(let error):
                    observer.send(error: .receiptVerificationFail)
                    print("Receipt verification failed: \(error)")
                }
            }
        }
    }
    
    func verifyCurrentSubscription() -> SignalProducer<VerifySubscriptionResult, IAPError> {
        return self.retrieveSharedSecret().flatMap(.concat) { sharedSecret -> SignalProducer<VerifySubscriptionResult, IAPError> in
            return self.verifyReceipt(productId: IAPProduct.proSubscription.rawValue, sharedSecret: sharedSecret)
        }
    }
}

