//
//  File.swift
//  LetsDinnerV2
//
//  Created by Alex Cheung on 24/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

public class GreyButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
        self.backgroundColor = Colors.paleGray
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
}
