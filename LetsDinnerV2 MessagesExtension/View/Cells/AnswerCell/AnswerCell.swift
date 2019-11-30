//
//  AnswerCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol AnswerCellDelegate: class {
    func addToCalendarAlert()
    func declineEventAlert()
}

class AnswerCell: UITableViewCell {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    
    weak var delegate: AnswerCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //
        acceptButton.clipsToBounds = true
        acceptButton.layer.cornerRadius = 6
        acceptButton.backgroundColor = Colors.paleGray
        declineButton.clipsToBounds = true
        declineButton.layer.cornerRadius = 6
        declineButton.backgroundColor = Colors.paleGray
            
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // After clicked Accept or Decline
//        if Event.shared.currentUser?.hasAccepted == true {
//            declineButton.isHidden = true
//        } else if Event.shared.currentUser?.hasAccepted == false {
//            acceptButton.isHidden = true
//        }
    }
    
    @IBAction func didTapAccept(_ sender: UIButton) {
        delegate?.addToCalendarAlert()
    }
    
    @IBAction func didTapDecline(_ sender: UIButton) {
        delegate?.declineEventAlert()
    }
}
