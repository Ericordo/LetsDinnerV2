//
//  LDServingsView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 20/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDServingsView: UIView {

    let label : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.textLabel
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    let stepper : UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 2
        stepper.maximumValue = 12
        stepper.stepValue = 1
        return stepper
    }()
    
    private let separator : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hide() {
        stepper.isHidden = true
        label.isHidden = true
        separator.isHidden = true
    }
    
    private func setup() {
        addSubview(separator)
        addSubview(label)
        addSubview(stepper)
        addConstraints()
    }
    
    private func addConstraints() {
        separator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        stepper.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}
