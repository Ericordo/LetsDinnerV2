//
//  LDNavButton.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDNavButton : UIButton {
    
    var isActive = true {
        didSet {
            isActive ? self.setTitleColor(UIColor.activeButton, for: .normal) : self.setTitleColor(UIColor.inactiveButton, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.setTitleColor(UIColor.activeButton, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
}
