//
//  RemoveConstraints.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 8/1/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func clearConstraints() {
        for subview in self.subviews {
            subview.clearConstraints()
        }
        self.removeConstraints(self.constraints)
    }
}
