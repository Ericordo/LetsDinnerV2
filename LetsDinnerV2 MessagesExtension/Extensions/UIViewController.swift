//
//  UIViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 24/2/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        self.present(viewControllerToPresent, animated: false)
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
        self.dismiss(animated: false)
    }
    
    @objc func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showBasicAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: AlertStrings.okAction,
                                   style: .default,
                                   handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true,
                     completion: nil)
    }
    
    func separator() -> UIView {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }
    
    func checkAuthenticationStatus() {
        let user = Auth.auth().currentUser
        if user == nil {
            self.reauthenticateUser()
        }
    }
    
    private func reauthenticateUser(showSuccess: Bool = false) {
        Auth.auth().signInAnonymously { _, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.showFailedAuthenticationAlert()
                } else if showSuccess {
                    self.showBasicAlert(title: AlertStrings.success,
                                        message: AlertStrings.loggedInSuccess)
                }
            }
        }
    }
    
    private func showFailedAuthenticationAlert() {
        let alert = UIAlertController(title: AlertStrings.oops,
                                      message: AlertStrings.userNotLoggedIn,
                                      preferredStyle: .alert)
        let connectAction = UIAlertAction(title: AlertStrings.connect,
                                          style: .default) { _ in
            self.reauthenticateUser(showSuccess: true)
        }
        alert.addAction(connectAction)
        self.present(alert,
                     animated: true,
                     completion: nil)
    }

    func createHorizontalStackView(image: UIImage, title: String, text: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        
        let icon = UIImageView(image: image.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)))
        icon.contentMode = .scaleAspectFit
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 60),
            icon.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let descriptionLabel : LDLabel = {
            let label = LDLabel()
            return label
        }()
        
        descriptionLabel.configureTextForWelcomeAndPremiumScreen(title: title, text: text)
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(descriptionLabel)
        
        return stackView
    }
}
