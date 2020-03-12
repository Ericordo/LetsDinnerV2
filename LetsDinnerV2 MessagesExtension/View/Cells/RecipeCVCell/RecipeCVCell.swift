//
//  RecipeCVCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class RecipeCVCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .backgroundColor
    }
    
    func configureCell(recipeTitle: String) {
        recipeLabel.text = recipeTitle
    }

}
