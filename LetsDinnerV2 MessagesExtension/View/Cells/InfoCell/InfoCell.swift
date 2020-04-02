//
//  InfoCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var cellSeparator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        infoLabel.textColor = .secondaryTextLabel
        
        self.backgroundColor = .backgroundColor
        
        cellSeparator.isHidden = true

    }

    
    
}
