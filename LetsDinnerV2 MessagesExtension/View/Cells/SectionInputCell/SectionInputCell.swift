//
//  SectionInputCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class SectionInputCell: UICollectionViewCell {
    
    @IBOutlet weak var sectionLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? UIColor.secondaryButtonBackground : .clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 8
        
        sectionLabel.backgroundColor = .clear
        sectionLabel.textAlignment = .center
        sectionLabel.layer.cornerRadius = 8
        sectionLabel.textColor = .textLabel
        sectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    func configure(sectionName: String) {
        sectionLabel.text = sectionName
    }
    
}
