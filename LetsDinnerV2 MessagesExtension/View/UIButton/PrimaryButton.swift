//
//  UIButton.swift
//  LetsDinnerV2
//
//  Created by Alex Cheung on 20/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//
import UIKit
import Foundation

public class PrimaryButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
        self.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
}


