//
//  CreateRecipeStartView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 15/4/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class CreateRecipeStartView: UIView {
    
    let scrollView : UIView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.textLabel
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = LabelStrings.startCreateRecipeTitle
        label.numberOfLines = 0
        return label
    }()
    
    let messageLabel1 : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.secondaryTextLabel
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.text = LabelStrings.startCreateRecipeMessage1
        label.numberOfLines = 0
//        label.textAlignment = .left
        return label
    }()
    
    let messageLabel2 : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.secondaryTextLabel
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.text = LabelStrings.startCreateRecipeMessage2
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    let messageLabel3 : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.secondaryTextLabel
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.text = LabelStrings.startCreateRecipeMessage3
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    let messageLabel4 : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.secondaryTextLabel
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.text = LabelStrings.startCreateRecipeMessage4
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    let buttonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "addButtonOutlined.png")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        self.backgroundColor = .backgroundColor
        
        self.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        self.addConstraints()
    }
    
    
    private func addConstraints() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel1.translatesAutoresizingMaskIntoConstraints = false
        messageLabel2.translatesAutoresizingMaskIntoConstraints = false
        messageLabel3.translatesAutoresizingMaskIntoConstraints = false
        messageLabel4.translatesAutoresizingMaskIntoConstraints = false
        buttonImage.translatesAutoresizingMaskIntoConstraints = false
        
        // ScrollView
        scrollView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
        
        // Container View
        containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        containerView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel1)
        containerView.addSubview(messageLabel2)
        containerView.addSubview(messageLabel3)
        containerView.addSubview(messageLabel4)
        containerView.addSubview(buttonImage)
 
        titleLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 30, left: 30, bottom: 0, right: 30))
        messageLabel1.anchor(top: titleLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 30, bottom: 0, right: 35))
        messageLabel2.anchor(top: messageLabel1.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 5, left: 30, bottom: 0, right: 35))
        messageLabel3.anchor(top: messageLabel2.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 5, left: 30, bottom: 0, right: 35))
        messageLabel4.anchor(top: messageLabel3.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 5, left: 30, bottom: 0, right: 0))
        
        buttonImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
//        buttonImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
        buttonImage.centerYAnchor.constraint(equalTo: messageLabel4.centerYAnchor).isActive = true
        buttonImage.leadingAnchor.constraint(equalTo: messageLabel4.trailingAnchor, constant: 5).isActive = true
    }
    

}

extension CreateRecipeStartView: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.x != 0 {
//            scrollView.contentOffset.x = 0
//        }
//    }
}
