//
//  ProgressCircle.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 09/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class ProgressCircle: UIView {
    
    let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
      required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
          configureView()
      }
    
    private func configureView() {
        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)

        let tracklayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: center, radius: self.frame.width/2 - 5, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2 , clockwise: true)
        tracklayer.path = circularPath.cgPath
        tracklayer.strokeColor = UIColor.lightGray.cgColor
        tracklayer.fillColor = UIColor.clear.cgColor
        tracklayer.lineWidth = 3
        self.layer.addSublayer(tracklayer)

        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = Colors.customPink.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.strokeEnd = 0
        shapeLayer.lineCap = .round
        self.layer.addSublayer(shapeLayer)
        self.clipsToBounds = true
    }
    
    func animate(percentage: CGFloat) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = percentage
        basicAnimation.duration = 3
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
    }

    
}





