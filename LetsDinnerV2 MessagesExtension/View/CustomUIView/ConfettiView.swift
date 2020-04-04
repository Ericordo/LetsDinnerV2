//
//  ConfettiView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/04/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import QuartzCore

class SAConfettiView: UIView {

    enum ConfettiType {
        case confetti
        case triangle
        case star
        case diamond
        case image(UIImage)
    }

    var emitter: CAEmitterLayer!
    public var colors: [UIColor]!
    public var intensity: Float!
    public var type: ConfettiType!
    private var active :Bool!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
            UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
            UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
            UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
            UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        intensity = 0.5
        type = .confetti
        active = false
    }

    func startConfetti() {
        emitter = CAEmitterLayer()

        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)

        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        active = true
    }

    func stopConfetti() {
        emitter?.birthRate = 0
        active = false
    }

    func imageForType(type: ConfettiType) -> UIImage? {
        switch type {
        case .confetti:
            return UIImage(named: "confetti")
        case .triangle:
            return UIImage(named: "triangle")
        case .star:
            return UIImage(named: "star")
        case .diamond:
            return UIImage(named: "diamond")
        case let .image(customImage):
            return customImage
        }
    }

    func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = imageForType(type: type)!.cgImage
        return confetti
    }

    public func isActive() -> Bool {
            return self.active
    }
}

