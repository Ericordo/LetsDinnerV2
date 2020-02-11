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
        button.setTitleColor(.black, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17)
        return button
    }()
    
    let lunchButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Lunch", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17)
        return button
    }()
    
    let dinnerButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Dinner", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17)
        return button
    }()
    
    let separatorOne : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 186/255, green: 191/255, blue: 197/255, alpha: 1.0)
        return view
    }()
    
    let separatorTwo : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 186/255, green: 191/255, blue: 197/255, alpha: 1.0)
        return view
    }()
    
    let stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        return sv
    }()
    
        private func configureView() {
            self.backgroundColor = Colors.inputGray
            self.sizeToFit()
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        override func layoutSubviews() {
            addConstraints()
        }
        
        private func addConstraints() {
            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            stackView.addArrangedSubview(breakfastButton)
            
            breakfastButton.translatesAutoresizingMaskIntoConstraints = false
            breakfastButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
            stackView.addArrangedSubview(separatorOne)
            separatorOne.translatesAutoresizingMaskIntoConstraints = false
          
            stackView.addArrangedSubview(lunchButton)
            lunchButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
            lunchButton.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(separatorTwo)
            separatorTwo.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(dinnerButton)
            dinnerButton.translatesAutoresizingMaskIntoConstraints = false
            dinnerButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
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
