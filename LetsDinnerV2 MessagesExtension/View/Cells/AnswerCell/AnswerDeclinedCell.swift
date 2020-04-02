//
//  AnswerCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class AnswerDeclinedCell: UITableViewCell {

    @IBOutlet weak var declineIcon: UIButton!
    @IBOutlet weak var declineLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .backgroundColor
        
        declineIcon.clipsToBounds = true
        declineIcon.layer.cornerRadius = declineIcon.frame.height / 2
        
        declineLabel.text = LabelStrings.declinedLabel
    }

    
}
