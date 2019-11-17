//
//  AnswerAcceptedCell.swift
//  LetsDinnerV2
//
//  Created by Alex Cheung on 18/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class AnswerAcceptedCell: UITableViewCell {

    @IBOutlet var acceptIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        acceptIcon.clipsToBounds = true
        acceptIcon.layer.cornerRadius = acceptIcon.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
