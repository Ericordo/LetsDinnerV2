//
//  IngredientCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 08/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

#warning("is it used?")
class IngredientCell: UITableViewCell {

    @IBOutlet weak var ingredientLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .backgroundColor
    }
    
    func configureCell(name: String, amount: Double, unit: String) {
        if amount == 0 {
            ingredientLabel.text = "\(name)"
            ingredientLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        } else {
            let attrs1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
            let attrs2 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
            let attributedString1 = NSMutableAttributedString(string: name, attributes: attrs1)
            let attributedString2 = NSMutableAttributedString(string: ", \(amount) \(unit)", attributes: attrs2)
            
            attributedString1.append(attributedString2)
            ingredientLabel.attributedText = attributedString1
        }
        
    }
    
    func configureCellWithStep(name: String, step: Int) {
        ingredientLabel.text = "\(step). \(name)"
    }
}
