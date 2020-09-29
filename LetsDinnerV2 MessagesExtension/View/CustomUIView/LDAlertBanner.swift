//
//  LDAlertBanner.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 20/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDAlertBanner: UIView {

    let warning : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textLabel
        return label
    }()
    
    private let separator : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    init(_ text: String) {
        super.init(frame: .zero)
        warning.text = text
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appear() {
        self.superview?.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.snp.updateConstraints { make in
                make.height.equalTo(60)
            }
            self.superview?.layoutIfNeeded()
        }
    }
    
    func disappear() {
        UIView.animate(withDuration: 0.2) {
            self.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            self.superview?.layoutIfNeeded()
        }
    }
    
    func appearAndDisappear() {
        self.appear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.2, animations: {
                self.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
                self.superview?.layoutIfNeeded()
            }) { _ in
                self.removeFromSuperview()
            }
        }
    }
    
    private func setup() {
        backgroundColor = .backgroundColor
        addSubview(separator)
        addSubview(warning)
        self.frame.size.height = 0
        addConstraints()
    }
    
    private func addConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        warning.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-17)
            make.bottom.equalTo(separator.snp.top)
            make.top.equalToSuperview()
        }
    }
}
