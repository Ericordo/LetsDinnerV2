//
//  LoadingView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 28/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.backgroundColor = UIColor.backgroundColor
        
        let imageName = "emptyPlate.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
           
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
}
