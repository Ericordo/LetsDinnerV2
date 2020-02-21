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
//            sectionLabel.font = isSelected ? UIFont.systemFont(ofSize: 16, weight: .semibold) : UIFont.systemFont(ofSize: 16, weight: .bold)
            sectionLabel.backgroundColor = isSelected ? Colors.paleGray : .backgroundColor
            self.backgroundColor = isSelected ? Colors.paleGray : .backgroundColor
        }
    }
    
    func setupCell() {
        self.layer.cornerRadius = 8
        sectionLabel.backgroundColor = .backgroundColor
        sectionLabel.textAlignment = .center
        sectionLabel.layer.cornerRadius = 8
        sectionLabel.textColor = .textLabel
        sectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.backgroundColor = .backgroundColor
    }
    
    func configureCell(sectionName: String) {
        sectionLabel.text = sectionName
        setupCell()
    }
    
}
