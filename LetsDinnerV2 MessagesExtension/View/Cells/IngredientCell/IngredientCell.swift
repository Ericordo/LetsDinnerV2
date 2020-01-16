//
//  IngredientCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 08/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class IngredientCell: UITableViewCell {

    @IBOutlet weak var ingredientLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    func configureCell(name: String, amount: Double, unit: String) {
        if amount == 0 {
            ingredientLabel.text = "\(name)"
        } else {
            ingredientLabel.text = "\(name), \(amount) \(unit)"
        }
        
    }
    
    func configureCellWithStep(name: String, step: Int) {
        ingredientLabel.text = "\(step). \(name)"
    }


    
}
