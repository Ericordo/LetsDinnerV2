//
//  NoNetworkViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 22/01/2021.
//  Copyright © 2021 Eric Ordonneau. All rights reserved.
//

import UIKit

class NoNetworkViewController: UIViewController {
    
    private let noNetworkImage : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = Images.noNetwork.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .backgroundMirroredColor
        return iv
    }()
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.noNetworkTitle
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .textLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private let descriptionLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.noNetworkDescription
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .secondaryTextLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        self.view.backgroundColor = .backgroundColor
        self.view.addSubview(titleLabel)
        self.view.addSubview(noNetworkImage)
        self.view.addSubview(descriptionLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        noNetworkImage.snp.makeConstraints { make in
            make.height.width.equalTo(70)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(titleLabel.font.lineHeight)
            make.top.equalTo(noNetworkImage.snp.bottom).offset(10)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
    }
}
