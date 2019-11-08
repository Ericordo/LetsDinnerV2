//
//  CalendarCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol CalendarCellDelegate: class {
    func calendarCellDidTapCalendarButton()
}

class CalendarCell: UITableViewCell {

    @IBOutlet weak var calendarButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    weak var delegate: CalendarCellDelegate?
    
    func setupCell() {
        calendarButton.layer.masksToBounds = true
        calendarButton.layer.cornerRadius = 8.0
        calendarButton.setGradient(colorOne: Colors.gradientRed, colorTwo: Colors.gradientPink)
    }
    
    override func layoutSubviews() {
              super.layoutSubviews()
              
          }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didTapCalendarButton(_ sender: UIButton) {
        delegate?.calendarCellDidTapCalendarButton()
    }
    
    
    
}
