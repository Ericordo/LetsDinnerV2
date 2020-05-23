//
//  CreateRecipeCookingStepTableViewCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 23/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class CreateRecipeCookingStepCell: UITableViewCell {

    @IBOutlet weak var stepNoLabel: UILabel!
    @IBOutlet weak var cookingStepLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stepNoLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
    }
    
    func configureCell(stepDetail: String, numberOfStep: Int) {
        stepNoLabel.text = String(numberOfStep) + "."
        
        cookingStepLabel.text = stepDetail
        cookingStepLabel.numberOfLines = 0
        cookingStepLabel.lineBreakMode = .byWordWrapping
        cookingStepLabel.sizeToFit()
    }

    
    

  
    
}
