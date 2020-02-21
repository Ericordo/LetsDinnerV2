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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        infoLabel.textColor = .secondaryTextLabel
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
