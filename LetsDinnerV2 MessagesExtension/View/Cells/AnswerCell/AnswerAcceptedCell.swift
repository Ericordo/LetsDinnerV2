//
//  AnswerAcceptedCell.swift
//  LetsDinnerV2
//
//  Created by Alex Cheung on 18/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class AnswerAcceptedCell: UITableViewCell {

    @IBOutlet weak var acceptIcon: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        acceptIcon.clipsToBounds = true
        acceptIcon.layer.cornerRadius = acceptIcon.frame.height / 2
        
        updateButton.layer.masksToBounds = true
        updateButton.layer.cornerRadius = 8.0
//        updateButton.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didTapUpdateButton(_ sender: Any) {
        //update
    }
}
