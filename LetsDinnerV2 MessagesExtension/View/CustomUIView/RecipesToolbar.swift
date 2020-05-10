//
//  RecipesToolbar.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class RecipesToolbar: UIView {
    
    lazy var createRecipeButton = toolbarItem(image: Images.addButtonOutlined)
    lazy var recipeToggle = toolbarItem(image: Images.recipeBookButtonOutlined)
    lazy var selectedRecipesButton = toolbarItem(image: Images.listButtonOutlined)
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.backgroundColor.withAlphaComponent(0.4)
        selectedRecipesButton.contentVerticalAlignment = .center
        selectedRecipesButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        selectedRecipesButton.setTitleColor(.activeButton, for: .normal)
        addBlurEffect()
        addSubview(createRecipeButton)
        addSubview(recipeToggle)
        addSubview(selectedRecipesButton)
        addConstraints()
    }
    
    private func addConstraints() {
        createRecipeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.height.width.equalTo(33)
            make.top.equalToSuperview().offset(13)
        }
        
        recipeToggle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(createRecipeButton.snp.centerY)
            make.height.width.equalTo(33)
        }
        
        selectedRecipesButton.snp.makeConstraints { make in
            make.height.equalTo(33)
            make.trailing.equalToSuperview().offset(-17)
            make.centerY.equalTo(createRecipeButton.snp.centerY)
        }
    }
    
    private func toolbarItem(image: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        return button
    }
    
    
}
