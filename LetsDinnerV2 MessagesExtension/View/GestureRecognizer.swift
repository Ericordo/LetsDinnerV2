//
//  GestureControl.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 30/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var slideGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var GestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.slideGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let GestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.slideGestureRecognizer) as? Action
            return GestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addSwipeGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.GestureRecognizerAction = action
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRightGesture(sender:)))
        self.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    
    // SwipeRight = go back
    @objc fileprivate func handleSwipeRightGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            if let action = self.GestureRecognizerAction {
                action?()
                print("Slide Right and go back")
            } else {
                print("no action")
            }
        }
    }
    
}

