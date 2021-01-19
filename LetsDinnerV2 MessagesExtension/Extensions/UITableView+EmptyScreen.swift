//
//  TableView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

// MARK: Empty Screen

extension UITableView {
    
    func setEmptyViewForRecipeView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel : UILabel = {
            let label = UILabel()
            label.textColor = UIColor.textLabel
            label.font = .systemFont(ofSize: 20, weight: .bold)
            label.text = title
            return label
        }()
        
        let messageLabel : UILabel = {
            let label = UILabel()
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 17, weight: .regular)
            label.text = message
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        let plateImageView : UIImageView = {
            let imageView = UIImageView()
            imageView.image = Images.emptyPlate
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        plateImageView.translatesAutoresizingMaskIntoConstraints = false
 
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(plateImageView)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        plateImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        plateImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        plateImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        plateImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -50).isActive = true
        
        // The only tricky part is here:
        self.backgroundView = emptyView
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
    func setEmptyViewForManagementVC(title: String, message: String, message2: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
                
        let titleLabel : UILabel = {
            let label = UILabel()
            label.textColor = UIColor.textLabel
            label.font = .systemFont(ofSize: 22, weight: .bold)
            label.text = title
            label.numberOfLines = 0
            label.textAlignment = .left
            return label
        }()
        
        let messageLabel : UILabel = {
            let label = UILabel()
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 17, weight: .regular)
            label.text = message
            label.numberOfLines = 0
            label.textAlignment = .left
            return label
        }()
        
        let messageLabel2 : UILabel = {
            let label = UILabel()
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 17, weight: .regular)
            label.text = message2
            label.numberOfLines = 0
            label.textAlignment = .left
            label.sizeToFit()
            return label
        }()
        
        let buttonImage: UIImageView = {
            let imageView = UIImageView()
            imageView.image = Images.addButtonOutlined
            return imageView
        }()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel2.translatesAutoresizingMaskIntoConstraints = false
        buttonImage.translatesAutoresizingMaskIntoConstraints = false

        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(messageLabel2)
        emptyView.addSubview(buttonImage)
                
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -100).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 30).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -30).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 30).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -50).isActive = true
        
        messageLabel2.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel2.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 30).isActive = true
        
        buttonImage.widthAnchor.constraint(equalToConstant: 22).isActive = true
        buttonImage.centerYAnchor.constraint(equalTo: messageLabel2.centerYAnchor).isActive = true
        buttonImage.leadingAnchor.constraint(equalTo: messageLabel2.trailingAnchor, constant: 5).isActive = true
        
        self.backgroundView = emptyView
    }
    
    func setEmptyViewForNoResults() {
        let emptyView = UIView(frame: CGRect(x: self.center.x,
                                             y: self.center.y,
                                             width: self.bounds.size.width,
                                             height: self.bounds.size.height))

        let messageLabel : UILabel = {
            let label = UILabel()
            label.textColor = UIColor.secondaryTextLabel
            label.font = .systemFont(ofSize: 17, weight: .regular)
            label.text = LabelStrings.noResults
            label.textAlignment = .center
            return label
        }()
        
        emptyView.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
        }

        self.backgroundView = emptyView
    }
    
    //MARK: Function
    
    func deselectSelectedRow(animated: Bool)
       {
           if let indexPathForSelectedRow = self.indexPathForSelectedRow {
               self.deselectRow(at: indexPathForSelectedRow, animated: animated)
           }
       }
}
