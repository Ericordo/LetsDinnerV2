//
//  LDLoadingView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDLoadingView: UIView {

    private let activityIndicator: UIActivityIndicatorView

    override init(frame: CGRect) {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.backgroundColor = .backgroundColor
        self.alpha = 1
        self.activityIndicator.color = .activeButton
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    func start() {
        self.activityIndicator.startAnimating()
    }
    
    func stop() {
        self.activityIndicator.stopAnimating()
        removeFromSuperview()
    }

}
