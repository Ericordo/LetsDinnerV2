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
    lazy var selectedRecipesButton = toolbarItem(image: Images.listButtonOutlined)
    
    lazy var apiRecipesButton = toolbarItem(image: Images.recipeBookButtonOutlined,
                                            tintColor: .inactiveButton)
    lazy var publicRecipesButton = toolbarItem(image: Images.discoverButtonOutlined,
                                               tintColor: .inactiveButton)
    lazy var myRecipesButton = toolbarItem(image: Images.recipeBookButtonOutlined,
                                           tintColor: .inactiveButton)
    
    
    private let searchTypeStackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .equalSpacing
        return sv
    }()
    
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
        addSubview(searchTypeStackView)
        searchTypeStackView.addArrangedSubview(apiRecipesButton)
        searchTypeStackView.addArrangedSubview(publicRecipesButton)
        searchTypeStackView.addArrangedSubview(myRecipesButton)
        addSubview(selectedRecipesButton)
        addConstraints()
    }
    
    private func addConstraints() {
        createRecipeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.height.width.equalTo(33)
            make.top.equalToSuperview().offset(13)
        }
        
        searchTypeStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(createRecipeButton.snp.centerY)
            make.height.equalTo(33)
            make.width.equalTo(139)
        }
        
        selectedRecipesButton.snp.makeConstraints { make in
            make.height.equalTo(33)
            make.trailing.equalToSuperview().offset(-17)
            make.centerY.equalTo(createRecipeButton.snp.centerY)
        }
    }
    
    func updateTintColor(_ searchType: SearchType) {
        switch searchType {
        case .apiRecipes:
            apiRecipesButton.tintColor = .activeButton
            publicRecipesButton.tintColor = .inactiveButton
            myRecipesButton.tintColor = .inactiveButton
        case .customRecipes:
            apiRecipesButton.tintColor = .inactiveButton
            publicRecipesButton.tintColor = .inactiveButton
            myRecipesButton.tintColor = .activeButton
        case .publicRecipes:
            apiRecipesButton.tintColor = .inactiveButton
            publicRecipesButton.tintColor = .activeButton
            myRecipesButton.tintColor = .inactiveButton
        }
    }
    
    private func toolbarItem(image: UIImage, tintColor: UIColor = .activeButton) -> UIButton {
        let button = UIButton()
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = tintColor
        return button
    }
}
