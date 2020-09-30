//
//  UIViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 24/2/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    var generator : UINotificationFeedbackGenerator {
        return UINotificationFeedbackGenerator()
    }

    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.layer.add(transition, forKey: kCATransition)

        present(viewControllerToPresent, animated: false)
    }

    func configureDismissVCTransitionAnimation(transition: VCTransitionDirection) {
        let transitionAnimation = CATransition()
        transitionAnimation.duration = 0.3
        transitionAnimation.type = CATransitionType.push
        
        switch transition {
        case .VCGoBack:
            transitionAnimation.subtype = CATransitionSubtype.fromLeft
        case .VCGoForward:
            transitionAnimation.subtype = CATransitionSubtype.fromRight
        case .VCGoUp:
            transitionAnimation.subtype = CATransitionSubtype.fromTop
        case .VCGoDown:
            transitionAnimation.subtype = CATransitionSubtype.fromBottom
        default:
            break
        }
        
        self.view.layer.add(transitionAnimation, forKey: kCATransition)

        dismiss(animated: false)
    }
    
    @objc func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showBasicAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: AlertStrings.okAction, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func separator() -> UIView {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }
}
