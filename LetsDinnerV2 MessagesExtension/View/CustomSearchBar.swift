//
//  CustomSearchBar.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSearchBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSearchBar()
    }
    
    private func setupSearchBar() {
//        self.layer.borderWidth = 0.1
//        self.layer.borderColor = UIColor(red:1 , green:1 , blue:1, alpha:1.0).cgColor
//        let image = UIColor(red:1, green:1, blue:1, alpha:1.0).image()
//        self.setBackgroundImage(image, for: .any, barMetrics: .default)
//        self.scopeBarBackgroundImage = image
        
        self.searchBarStyle = .minimal
        self.barTintColor = .backgroundColor
        self.backgroundColor = .backgroundColor
        self.isTranslucent = true
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                self.searchTextField.backgroundColor = UIColor.backgroundColor.withAlphaComponent(1.0)
            }
        }
    }

}
