//
//  LDSearchBar.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configure() {
        self.searchBarStyle = .minimal
        self.barTintColor = .backgroundColor
        self.backgroundColor = .backgroundColor
        self.tintColor = .activeButton
        self.isTranslucent = true
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                self.searchTextField.backgroundColor = UIColor.backgroundColor.withAlphaComponent(1.0)
            }
        }
    }
}
