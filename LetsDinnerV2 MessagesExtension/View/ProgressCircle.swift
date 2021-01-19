//
//  ProgressCircle.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 09/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class ProgressCircle: UIView {
    
    private let innerCircle = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
      required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
      }
    
    private func configureView() {
        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        let outsideCircle = CAShapeLayer()
        let outsideRadius = self.frame.width/2 - 5
        let outsidePath = UIBezierPath(arcCenter: center, radius: outsideRadius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi , clockwise: true)
        
        outsideCircle.path = outsidePath.cgPath
        outsideCircle.strokeColor = UIColor.textLabel.cgColor
        outsideCircle.fillColor = UIColor.clear.cgColor
        outsideCircle.lineWidth = 1
        self.layer.addSublayer(outsideCircle)
        
        let innerRadius: CGFloat = outsideRadius - 2.5
        let endAngle = 3 * CGFloat.pi / 2
        let innerPath = UIBezierPath(arcCenter: center, radius: innerRadius/2, startAngle: -CGFloat.pi / 2 , endAngle: endAngle, clockwise: true)
        
        innerCircle.path = innerPath.cgPath
        innerCircle.strokeColor = UIColor.textLabel.cgColor
        innerCircle.fillColor = UIColor.clear.cgColor
        innerCircle.lineWidth = innerRadius
        innerCircle.strokeEnd = 0
        
        self.layer.addSublayer(innerCircle)
    }
    
    @objc func animate(percentage: Double) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = roundUp(percentage, toNearest: 0.1)
        basicAnimation.duration = 2 * percentage
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        innerCircle.add(basicAnimation, forKey: "basicAnimation")
    }
    
    private func roundUp(_ value: Double, toNearest: Double) -> Double {
        return ceil(value / toNearest) * toNearest
    }
}





