//
//  CreateRecipeCommentCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 12/7/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class CreateRecipeCommentCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .backgroundColor
    }

    func configureCell(comment: String) {
        commentLabel.text = comment
        commentLabel.numberOfLines = 0
        commentLabel.lineBreakMode = .byWordWrapping
        commentLabel.sizeToFit()
    }
}
