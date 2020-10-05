//
//  LDRescheduleView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 27/01/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDRescheduleView: UIView {
    
    private let datePicker = LDDatePicker()
    
    private let titleLabel : LDLabel = {
        let label = LDLabel(title: LabelStrings.rescheduleTitle,
                            text: LabelStrings.rescheduleText)
        return label
    }()
        
    let updateButton : PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(LabelStrings.update, for: .normal)
        return button
    }()
    
    private let dragIndicator: UIView = {
        let indicator = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 5))
        indicator.backgroundColor = UIColor.keyboardBackground
        indicator.layer.cornerRadius = 3
        return indicator
    }()
    
    let height = 431
    
    private(set) var selectedDate : Double = Event.shared.dateTimestamp
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        resetDate()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didSelectDate(sender: UIDatePicker) {
        selectedDate = sender.date.timeIntervalSince1970
        updateButton.isEnabled = selectedDate != Event.shared.dateTimestamp
    }
    
    func resetDate() {
        datePicker.date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
        selectedDate = Event.shared.dateTimestamp
        updateButton.isEnabled = false
    }
    
    private func setupView() {
        self.layer.cornerRadius = 20
        self.backgroundColor = .backgroundColor
//        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        datePicker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)
        self.backgroundColor = .backgroundColor
        self.addSubview(updateButton)
        self.addSubview(dragIndicator)
        self.addSubview(titleLabel)
        self.addSubview(datePicker)
        addConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !UIDevice.current.hasHomeButton {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: self.bounds,
                                          byRoundingCorners: [.bottomLeft, .bottomRight],
                                          cornerRadii: CGSize(width: 38.5, height: 38.5)).cgPath
            self.layer.mask = maskLayer
        }
    }
    
    private func addConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        
        updateButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        
        dragIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(5)
            make.width.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dragIndicator.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(updateButton.snp.top).offset(-10)
        }
    }
}

