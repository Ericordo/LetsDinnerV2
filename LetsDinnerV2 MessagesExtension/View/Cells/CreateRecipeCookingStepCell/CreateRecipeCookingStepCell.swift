//
//  CreateRecipeCookingStepTableViewCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 23/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class CreateRecipeCookingStepCell: UITableViewCell {

    @IBOutlet weak var stepNumberLabel: UILabel!
    @IBOutlet weak var cookingStepLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .backgroundColor
        stepNumberLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    
    func configureCell(stepDetail: String, stepNumber: Int) {
        stepNumberLabel.text = String(stepNumber) + "."
        
        cookingStepLabel.text = stepDetail
        cookingStepLabel.numberOfLines = 0
        cookingStepLabel.lineBreakMode = .byWordWrapping
        cookingStepLabel.sizeToFit()
    }
}
