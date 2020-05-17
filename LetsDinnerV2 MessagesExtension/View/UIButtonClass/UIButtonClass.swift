//
//  UIButton.swift
//  LetsDinnerV2
//
//  Created by Alex Cheung on 20/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//
import UIKit
import Foundation

#warning("wtf is that")
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

class SecondaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        backgroundColor = UIColor.secondaryButtonBackground
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        setTitleColor(.textLabel, for: .normal)
    }
}

public class TertiaryButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
        self.backgroundColor = UIColor.tertiaryButtonBackground
        self.setTitleColor(UIColor.textLabel, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
    }
}


