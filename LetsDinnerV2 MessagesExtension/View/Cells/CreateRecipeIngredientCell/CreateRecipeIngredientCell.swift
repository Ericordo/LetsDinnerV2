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
    
    func configureCell(name: String, amount: Double?, unit: String?) {
        
        ingredientLabel.text = name
        
        if let amount = amount {
            amountLabel.text = String(amount)
            
            if let unit = unit {
                amountLabel.text! += " " + unit
            }
            
        } else {
            amountLabel.text = ""
            
            ingredientLabel.snp.makeConstraints{ make in
                make.centerY.equalToSuperview()
            }
        }
        
        
        
    }

    
}
