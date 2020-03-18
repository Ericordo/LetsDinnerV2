//
//  SFSafariViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 15/02/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import SafariServices

extension SFSafariViewController {
    
    func registerForNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
    }
//    
//    @objc private func closeVC() {
//        dismiss(animated: true, completion: nil)
//    }
    
    
}
