//
//  EventInputView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 18/01/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import UIKit

class EventInputView: UIView {
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    let breakfastButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Breakfast", for: .normal)
        button.setTitleColor(.textLabel, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    let lunchButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Lunch", for: .normal)
        button.setTitleColor(.textLabel, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    let dinnerButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Dinner", for: .normal)
        button.setTitleColor(.textLabel, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    let separatorOne : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.keyboardSeparator
        return view
    }()
    
    let separatorTwo : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.keyboardSeparator
        return view
    }()
    
    let stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillProportionally
        sv.alignment = .center
        return sv
    }()
    
    private func configureView() {
        self.backgroundColor = UIColor.keyboardBackground
        self.sizeToFit()
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addConstraints()
        
    }
    
    private func addConstraints() {
        addSubview(stackView)
        
        let buttonWidth = self.frame.width / 3
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        // In Order
        stackView.addArrangedSubview(breakfastButton)
        stackView.addArrangedSubview(separatorOne)
        stackView.addArrangedSubview(lunchButton)
        stackView.addArrangedSubview(separatorTwo)
        stackView.addArrangedSubview(dinnerButton)
        
        // Remove Constraints (For Rotation)
        breakfastButton.removeAllConstraints()
        lunchButton.removeAllConstraints()
        dinnerButton.removeAllConstraints()

        breakfastButton.translatesAutoresizingMaskIntoConstraints = false
        separatorOne.translatesAutoresizingMaskIntoConstraints = false
        lunchButton.translatesAutoresizingMaskIntoConstraints = false
        separatorTwo.translatesAutoresizingMaskIntoConstraints = false
        dinnerButton.translatesAutoresizingMaskIntoConstraints = false

        breakfastButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        lunchButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        dinnerButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        breakfastButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        lunchButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        dinnerButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        
        NSLayoutConstraint.activate([
            separatorOne.widthAnchor.constraint(equalToConstant: 1),
            separatorOne.topAnchor.constraint(equalTo: self.topAnchor, constant: 14),
            separatorOne.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            separatorTwo.widthAnchor.constraint(equalToConstant: 1),
            separatorTwo.topAnchor.constraint(equalTo: self.topAnchor, constant: 14),
            separatorTwo.heightAnchor.constraint(equalToConstant: 24)
        ])
        
    }
        
}
