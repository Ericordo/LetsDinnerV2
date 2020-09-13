//
//  CreateRecipeIngredientTableViewCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 17/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class CreateRecipeIngredientCell: UITableViewCell {
    
    static let reuseID = "CreateRecipeIngredientCell"

    private let ingredientLabel : UILabel = {
        let label = UILabel()
        label.textColor = .textLabel
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let amountLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    private let stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .leading
        sv.distribution = .fillProportionally
        return sv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(ingredient: LDIngredient) {
        let name = ingredient.name
        let amount = ingredient.amount
        let unit = ingredient.unit
        ingredientLabel.text = name
        if let amount = amount {
            amountLabel.text = amount.trailingZero
            if let unit = unit {
                amountLabel.text = (amountLabel.text ?? "") + " \(unit)"
            }
            stackView.snp.updateConstraints { make in
                make.height.greaterThanOrEqualTo(60)
            }
        } else {
            amountLabel.text = ""
            stackView.snp.updateConstraints { make in
                make.height.greaterThanOrEqualTo(44)
            }
        }
    }
    
    private func setupUI() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        self.contentView.addSubview(stackView)
        stackView.addArrangedSubview(ingredientLabel)
        stackView.addArrangedSubview(amountLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        stackView.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.greaterThanOrEqualTo(60)
        }
    }
}
