//
//  LandscapeViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 10/11/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    private let instructionLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.landscapeInstruction
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .secondaryTextLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .backgroundColor
        view.addSubview(instructionLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        instructionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalToSuperview().offset(50)
        }
    }
}
