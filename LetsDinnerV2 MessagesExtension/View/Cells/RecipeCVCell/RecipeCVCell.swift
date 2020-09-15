//
//  RecipeCVCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class RecipeCVCell: UICollectionViewCell {
    
    static let reuseID = "RecipeCVCell"
    
    private let recipeLabel : UILabel = {
        let label = UILabel()
        label.textColor = .activeButton
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(recipeTitle: String) {
        recipeLabel.text = recipeTitle
    }
    
    private func setupCell() {
        self.backgroundColor = .backgroundColor
        contentView.addSubview(recipeLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        recipeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
