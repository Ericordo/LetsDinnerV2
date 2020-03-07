//
//  UITableViewCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 7/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

extension UITableViewCell {

    /// Returns label of cell action button.
    ///
    /// Use this property to set cell action button label color.
    var cellActionButtonLabel: UILabel? {
        for subview in self.superview?.subviews ?? [] {
            if String(describing: subview).range(of: "UISwipeActionPullView") != nil {
                for view in subview.subviews {
                    if String(describing: view).range(of: "UISwipeActionStandardButton") != nil {
                        for sub in view.subviews {
                            if let label = sub as? UILabel {
                                return label
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func fadeIn(duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
          self.alpha = 1.0
      })
    }

    func fadeOut(duration: TimeInterval = 5.0) {
        UIView.animate(withDuration: duration, animations: {
          self.alpha = 0.0
      })
    }
}
