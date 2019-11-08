//
//  UserCVCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 08/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class UserCVCell: UICollectionViewCell {
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(user: User) {
        var strokeColor = UIColor()
        strokeColor = user.hasAccepted ? Colors.hasAccepted : Colors.hasDeclined
        userPicture.setImage(string: user.fullName.initials, color: .lightGray, circular: true, stroke: true, strokeColor: strokeColor, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 20, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
        nameLabel.text = user.fullName
    }

}
