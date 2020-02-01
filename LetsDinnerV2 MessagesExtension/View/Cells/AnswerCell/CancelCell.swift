//
//  CancelCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 26/01/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol CancelCellDelegate: class {
    func postponeEvent()
    func cancelEvent()
}

class CancelCell: UITableViewCell {
    
    @IBOutlet weak var postponeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: CancelCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        postponeButton.layer.cornerRadius = 6
        cancelButton.layer.cornerRadius = 6
    }
    
    
    @IBAction func didTapPostpone(_ sender: Any) {
        delegate?.postponeEvent()
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        delegate?.cancelEvent()
    }
    
    
}