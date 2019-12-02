//
//  UITextField.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 20/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

extension UITextField {
    func animateEmpty() {
        if self.text == "" {
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                
//                     self.layer.borderColor = Colors.newGradientPink.cgColor
//                     self.layer.borderWidth = 2
//                self.backgroundColor?.withAlphaComponent(1)
            
        
                
                    
                 }) { (_) in
                     self.shake()
                    self.layer.borderWidth = 0
                    
                 }
        }
    }
    
    
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
    

      func setLeftView(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20)) // set your Own size
        iconView.contentMode = .scaleAspectFit
        iconView.image = image
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 20))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
        
      }
    
}


