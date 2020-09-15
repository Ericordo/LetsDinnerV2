//
//  SectionInputCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class SectionInputCell: UICollectionViewCell {
    
    static let reuseID = "SectionInputCell"
    
    private let sectionLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.textColor = .textLabel
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? UIColor.secondaryButtonBackground : .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(sectionName: String) {
        sectionLabel.text = sectionName
    }
    
    private func setupCell() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 8
        self.backgroundColor = .backgroundColor
        contentView.addSubview(sectionLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        sectionLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(5)
            make.trailing.bottom.equalToSuperview().offset(-5)
        }
    }
}
