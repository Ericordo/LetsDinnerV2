//
//  UIView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 02/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setGradient(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setGradientToValue(colorOne: UIColor, colorTwo: UIColor, value: Double) {
         let gradientLayer = CAGradientLayer()
         gradientLayer.frame = bounds
         gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
         gradientLayer.locations = [0.0, 1.0]
         gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
         gradientLayer.endPoint = CGPoint(x: 0.5, y: value)
         layer.insertSublayer(gradientLayer, at: 0)
     }
    
    func rotate() {
        if self.transform == .identity {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(rotationAngle: -CGFloat((Double.pi/2)))
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }

    
}
