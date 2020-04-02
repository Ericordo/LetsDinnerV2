//
//  AlertManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 29/03/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import UIKit

class AlertManager {
    
    static let shared = AlertManager()
    
    private init() {}
    
    func showBasicAlert(for viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: title, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        viewController.present(viewController, animated: true, completion: nil)
    }
    
    
    
}
