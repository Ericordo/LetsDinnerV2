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
    
    func declineInvitation() 
}

class AnswerCell: UITableViewCell {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var acceptedLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var declinedLabel: UILabel!
    
    
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
        acceptedLabel.isHidden = true
        declinedLabel.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(animateDecline), name: Notification.Name(rawValue: "TappedDecline"), object: nil)
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
        self.acceptButton.setTitle("", for: .normal)
        self.declineButton.isHidden = true
        stackView.distribution = .fillProportionally
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.stackView.spacing = 10
            self.acceptButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
            self.acceptedLabel.isHidden = false
            self.acceptButton.layer.cornerRadius = self.acceptButton.frame.size.height / 2
        }) { (_) in
            self.delegate?.addToCalendarAlert()
        }
    }
    
    @IBAction func didTapDecline(_ sender: UIButton) {
        delegate?.declineEventAlert()
    }
    
    
    @objc func animateDecline() {
        self.declineButton.setTitle("", for: .normal)
        self.acceptButton.isHidden = true
        stackView.distribution = .fillProportionally
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.stackView.spacing = 10
            self.declineButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
            self.declinedLabel.isHidden = false
            self.declineButton.layer.cornerRadius = self.acceptButton.frame.size.height / 2
        }) { (_) in
            self.delegate?.declineInvitation()
        }
    }
}


 
    
    

