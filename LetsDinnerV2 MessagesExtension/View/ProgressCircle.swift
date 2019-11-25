//
//  ProgressCircle.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 09/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class ProgressCircle: UIView {
    
//    let shapeLayer = CAShapeLayer()
    let innerCircle = CAShapeLayer()
    
//    let percentageLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.text = "100%"
//        label.textColor = .black
//        label.font = UIFont.boldSystemFont(ofSize: 5)
//        return label
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
      required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
          configureView()
      }
    
//    private func configureView() {
////        self.addSubview(percentageLabel)
////        percentageLabel.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
////        percentageLabel.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
//
//        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
//
//        let tracklayer = CAShapeLayer()
//        let circularPath = UIBezierPath(arcCenter: center, radius: self.frame.width/2 - 5, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2 , clockwise: true)
//        tracklayer.path = circularPath.cgPath
//        tracklayer.strokeColor = UIColor.lightGray.cgColor
//        tracklayer.fillColor = UIColor.clear.cgColor
//        tracklayer.lineWidth = 3
//        self.layer.addSublayer(tracklayer)
//
//        shapeLayer.path = circularPath.cgPath
//        shapeLayer.strokeColor = Colors.customPink.cgColor
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineWidth = 3
//        shapeLayer.strokeEnd = 0
//        shapeLayer.lineCap = .round
//        self.layer.addSublayer(shapeLayer)
//        self.clipsToBounds = true
//    }
    
    func configureView() {
        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        let outsideCircle = CAShapeLayer()
        let outsideRadius = self.frame.width/2 - 5
        let outsidePath = UIBezierPath(arcCenter: center, radius: outsideRadius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi , clockwise: true)
        
        outsideCircle.path = outsidePath.cgPath
        outsideCircle.strokeColor = UIColor.lightGray.cgColor
        outsideCircle.fillColor = UIColor.clear.cgColor
        outsideCircle.lineWidth = 1
        self.layer.addSublayer(outsideCircle)
        
        let innerRadius: CGFloat = outsideRadius - 2.5
        let endAngle = 3 * CGFloat.pi / 2
        let innerPath = UIBezierPath(arcCenter: center, radius: innerRadius/2, startAngle: -CGFloat.pi / 2 , endAngle: endAngle, clockwise: true)
        
        innerCircle.path = innerPath.cgPath
        innerCircle.strokeColor = UIColor.lightGray.cgColor
        innerCircle.fillColor = UIColor.clear.cgColor
        innerCircle.lineWidth = innerRadius
        innerCircle.strokeEnd = 0
        
        self.layer.addSublayer(innerCircle)
        
    }
    
//    func animate(percentage: CGFloat) {
//        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        basicAnimation.toValue = percentage
//        basicAnimation.duration = 1
//        basicAnimation.fillMode = .forwards
//        basicAnimation.isRemovedOnCompletion = false
//        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
//    }
    
    @objc func animate(percentage: Double) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = roundUp(percentage, toNearest: 0.1)
        basicAnimation.duration = 2 * percentage
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        innerCircle.add(basicAnimation, forKey: "basicAnimation")
    }
    
    func roundUp(_ value: Double, toNearest: Double) -> Double {
        return ceil(value / toNearest) * toNearest
    }
    

    
}





