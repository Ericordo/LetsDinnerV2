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
        self.layer.borderWidth = 0.1
        self.layer.borderColor = UIColor(red:1 , green:1 , blue:1, alpha:1.0).cgColor
        let image = UIColor(red:1, green:1, blue:1, alpha:1.0).image()
        self.setBackgroundImage(image, for: .any, barMetrics: .default)
        self.scopeBarBackgroundImage = image
        self.barTintColor = .clear
        self.backgroundColor = .clear
        self.isTranslucent = true
        self.searchBarStyle = .prominent
    }

}
