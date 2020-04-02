//
//  ProgressBar.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 13/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

/* Not using
 
import UIKit

class ProgressBar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    private func configureView() {
        backgroundColor = Colors.newGradientRed
    }
    
    
    func animateProgress(view: UIView, currentStep: Int, constraint: NSLayoutConstraint) {
        UIView.animate(withDuration: 3, animations: {
            constraint.constant = 0
            constraint.constant = (view.frame.width/CGFloat(4)) * CGFloat(currentStep)

        })
    }
    
}
 
 */
