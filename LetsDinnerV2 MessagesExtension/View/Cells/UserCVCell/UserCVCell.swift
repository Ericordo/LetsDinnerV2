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
        
        if let imageURL = URL(string: user.profilePicUrl!) {
            userPicture.layer.cornerRadius = userPicture.frame.height/2
            userPicture.clipsToBounds = true
            userPicture.layer.borderWidth = 2.0
            userPicture.layer.borderColor = strokeColor.cgColor
            userPicture.kf.setImage(with: imageURL)
        } else {
            userPicture.setImage(string: user.fullName.initials, color: .lightGray, circular: true, stroke: true, strokeColor: strokeColor, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 20, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        
        
        
        nameLabel.text = user.fullName
    }

}
