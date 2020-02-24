//
//  LDLabel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 24/02/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
       
    }
    
    convenience init(title: String, text: String) {
        self.init(frame: .zero)
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.textLabel]))
        attributedString.append(NSAttributedString(string: "\n"))
        attributedString.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.secondaryTextLabel]))
        self.attributedText = attributedString
    }
    

    
    private func configure() {
        numberOfLines = 0
    }
    
    

}
