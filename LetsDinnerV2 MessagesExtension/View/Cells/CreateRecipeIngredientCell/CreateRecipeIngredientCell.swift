//
//  CreateRecipeIngredientTableViewCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 17/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class CreateRecipeIngredientCell: UITableViewCell {

    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(ingredient: LDIngredient) {
        let name = ingredient.name
        let amount = ingredient.amount
        let unit = ingredient.unit
        
        ingredientLabel.text = name
        
        if let amount = amount {
            amountLabel.text = String(amount)
            
            if let unit = unit {
                amountLabel.text! += " " + unit
            }
            
        } else {
            // If amount == nil
            amountLabel.text = ""
            
//            ingredientLabel.snp.makeConstraints{ make in
//                make.centerY.equalToSuperview()
//            }
        }
        
        
        
    }

    
}
