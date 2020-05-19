//
//  UIButton.swift
//  LetsDinnerV2
//
//  Created by Alex Cheung on 20/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//
import UIKit
import Foundation


class PrimaryButton: UIButton {
    #warning("make sure all these buttons are actually using this subclass")
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
    }
    
    private func setup() {
        self.frame = CGRect(origin: .zero, size: CGSize(width: 56, height: 253))
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        self.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.width.equalTo(253)
        }
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

class TertiaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
        self.backgroundColor = UIColor.tertiaryButtonBackground
        self.setTitleColor(UIColor.textLabel, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
    }
}


