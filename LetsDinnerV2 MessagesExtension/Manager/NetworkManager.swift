//
//  NetworkManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 22/01/2021.
//  Copyright © 2021 Eric Ordonneau. All rights reserved.
//

import Foundation

class NetworkManager: NSObject {
    
    var reachability: Reachability
    
    // Create a singleton instance
    static let shared: NetworkManager = { return NetworkManager() }()
    
    override init() {
        
        // Initialise reachability
        self.reachability = try! Reachability()
        
        super.init()
        
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
        print("network status changed")
//        let reachability = try! Reachability()
        if reachability.connection == .unavailable {
             print("no interet")
         } else {
             print("internet")
         }
    }
    
    static func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (NetworkManager.shared.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.shared.reachability).connection != .unavailable {
            completed(NetworkManager.shared)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.shared.reachability).connection == .unavailable {
            completed(NetworkManager.shared)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.shared.reachability).connection == .cellular {
            completed(NetworkManager.shared)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.shared.reachability).connection == .wifi {
            completed(NetworkManager.shared)
        }
    }
}
