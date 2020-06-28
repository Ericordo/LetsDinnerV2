//
//  LostEventView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 28/06/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LostEventView: UIView {
    
    private let infoLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .textLabel
        label.textAlignment = .center
        label.text = LabelStrings.eventUnavailable
        return label
    }()
    
    private let logo : UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.mealPlaceholder
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(superView: UIView) {
        superView.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setup() {
        self.backgroundColor = .backgroundColor
        self.addSubview(logo)
        self.addSubview(infoLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        logo.snp.makeConstraints { make in
            make.height.width.equalTo(90)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.leading.equalToSuperview().offset(30)
        }
    }
}
