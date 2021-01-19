//
//  TaskPersonLabel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class TaskPersonLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = .systemFont(ofSize: 13)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTextAttributes(userOwnsTask: Bool) {
        self.textColor = userOwnsTask ? .activeButton : .secondaryTextLabel
    }
}
