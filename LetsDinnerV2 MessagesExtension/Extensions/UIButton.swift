//
//  UIButton.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

extension UIButton {
    func shake() {
          let shake = CABasicAnimation(keyPath: "position")
          shake.duration = 0.1
          shake.repeatCount = 2
          shake.autoreverses = true
          
          let fromPoint = CGPoint(x: center.x-5, y: center.y)
          let fromValue = NSValue(cgPoint: fromPoint)
          
          let toPoint = CGPoint(x: center.x+5, y: center.y)
          let toValue = NSValue(cgPoint: toPoint)
          
          shake.fromValue = fromValue
          shake.toValue = toValue
          
          layer.add(shake, forKey: nil)
      }
    
    
    
//    func rotate() {
//        if self.transform == .identity {
//            UIView.animate(withDuration: 0.2) {
//                self.transform = CGAffineTransform(rotationAngle: -CGFloat((Double.pi/2)))
//            }
//        } else {
//            UIView.animate(withDuration: 0.2) {
//                self.transform = .identity
//            }
//        }
//    }
    

    
    
}


