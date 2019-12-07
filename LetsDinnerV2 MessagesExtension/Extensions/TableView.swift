//
//  TableView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

extension UITableView {
    
    func setEmptyView(title: String, message: String) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel : UILabel = {
            let label = UILabel()
            label.textColor = UIColor.black
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            label.text = title
            return label
        }()
        
        let messageLabel : UILabel = {
            let label = UILabel()
            label.textColor = UIColor.lightGray
            label.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
            label.text = message
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        let plateImageView : UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "emptyPlate")
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
        
        UIView.animate(withDuration: 1, animations: {
            plateImageView.transform = CGAffineTransform(rotationAngle: .pi / 5)
        }, completion: { (finish) in
            UIView.animate(withDuration: 1, animations: {
                plateImageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 5))
            }, completion: { (finish) in
                UIView.animate(withDuration: 1, animations: {
                   plateImageView.transform = CGAffineTransform.identity
                })
            })
        })
        
        
        // The only tricky part is here:
        self.backgroundView = emptyView
        
    }
    func restore() {
        self.backgroundView = nil
    }
}
