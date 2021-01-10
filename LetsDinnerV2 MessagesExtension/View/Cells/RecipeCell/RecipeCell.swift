//
//  RecipeCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import Kingfisher

protocol RecipeCellDelegate: class {
    func recipeCellDidSelectRecipe(_ recipe: Recipe)
    func recipeCellDidSelectCustomRecipe(_ customRecipe: LDRecipe)
    func recipeCellDidSelectPublicRecipe(_ publicRecipe: LDRecipe)
    func recipeCellDidSelectView(_ recipe: Recipe)
    func recipeCellDidSelectCustomRecipeView(_ recipe: LDRecipe)
}

class RecipeCell: UITableViewCell {
    
    static let reuseID = "RecipeCell"
    
    private let backgroundCellView : UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .backgroundColor
        return view
    }()
    
    private let backgroundImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var visualEffectView : UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = backgroundImageView.bounds
        return blurredEffectView
    }()
    
    private lazy var vibrancyEffectView : UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = backgroundImageView.bounds
        return vibrancyEffectView
    }()
    
    private let recipeImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.kf.indicatorType = .activity
        return imageView
    }()
    
    private let recipeNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .textLabel
        return label
    }()
    
    private lazy var viewButton : TertiaryButton = {
        let button = TertiaryButton()
        
        button.setTitle(ButtonTitle.open, for: .normal)
        button.addTarget(self, action: #selector(didTapViewButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var chooseButton : TertiaryButton = {
        let button = TertiaryButton()
        button.setTitle(ButtonTitle.add, for: .normal)
        button.addTarget(self, action: #selector(didTapChooseButton), for: .touchUpInside)
        return button
    }()
    
    lazy var chosenButton : UIButton = {
        let button = UIButton()
        button.setImage(Images.checkedButton, for: .normal)
        button.addTarget(self, action: #selector(didTapChosenButton), for: .touchUpInside)
        return button
    }()
    
    var selectedRecipe = Recipe(dict: [:])
    var selectedCustomRecipe = LDRecipe()
    var selectedPublicRecipe = LDRecipe()
    var searchType: SearchType = .apiRecipes

    weak var recipeCellDelegate: RecipeCellDelegate?
     
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOSApplicationExtension 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                let blurEffect = UIBlurEffect(style: .dark)
                self.visualEffectView.effect = blurEffect
            }
        }
    }

    func setupCell() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.selectionStyle = .none
        self.contentView.addSubview(backgroundCellView)
        self.backgroundCellView.addSubview(backgroundImageView)
        self.backgroundCellView.addSubview(visualEffectView)
        self.visualEffectView.contentView.addSubview(vibrancyEffectView)
        self.backgroundCellView.addSubview(recipeImageView)
        self.backgroundCellView.addSubview(viewButton)
        self.backgroundCellView.addSubview(chooseButton)
        self.backgroundCellView.addSubview(chosenButton)
        self.backgroundCellView.addSubview(recipeNameLabel)
        addConstraints()
    }
    
    func updateHeight(with value: CGFloat) {
        backgroundCellView.snp.updateConstraints { make in
            make.height.equalTo(value)
        }
        backgroundCellView.layoutIfNeeded()
    }
    
    private func addConstraints() {
        self.backgroundCellView.snp.makeConstraints { make in
            make.height.equalTo(110)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        vibrancyEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        recipeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(90)
        }
        
        viewButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.leading.equalTo(recipeImageView.snp.trailing).offset(15)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        chooseButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalTo(viewButton)
        }
        
        chosenButton.snp.makeConstraints { make in
            make.height.equalTo(31)
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalTo(chooseButton)
        }
        
        recipeNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(recipeImageView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalTo(recipeImageView.snp.top)
        }
    }
    
    func configureCell(_ recipe: Recipe) {
        self.configureRecipeImage(recipe.imageUrl)
        self.searchType = .apiRecipes
        recipeNameLabel.text = recipe.title
        selectedRecipe = recipe
        chooseButton.isHidden = recipe.isSelected
        chosenButton.isHidden = !recipe.isSelected
        recipeNameLabel.sizeToFit()
    }
    
    func configureCellWithCustomRecipe(_ customRecipe: LDRecipe) {
        self.configureRecipeImage(customRecipe.downloadUrl)
        self.searchType = .customRecipes
        recipeNameLabel.text = customRecipe.title
        selectedCustomRecipe = customRecipe
        chooseButton.isHidden = customRecipe.isSelected
        chosenButton.isHidden = !customRecipe.isSelected
    }
    
    func configureCellWithPublicRecipe(_ publicRecipe: LDRecipe) {
        self.configureRecipeImage(publicRecipe.downloadUrl)
        self.searchType = .publicRecipes
        recipeNameLabel.text = publicRecipe.title
        selectedPublicRecipe = publicRecipe
        chooseButton.isHidden = publicRecipe.isPublicAndSelected
        chosenButton.isHidden = !publicRecipe.isPublicAndSelected
    }
    
    private func configureRecipeImage(_ downloadUrl: String?) {
        if let downloadUrl = downloadUrl {
            recipeImageView.kf.setImage(with: URL(string: downloadUrl))
            backgroundImageView.kf.setImage(with: URL(string: downloadUrl))
            visualEffectView.isHidden = false
            if #available(iOSApplicationExtension 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    let blurEffect = UIBlurEffect(style: .dark)
                    self.visualEffectView.effect = blurEffect
                }
            }
        } else {
            recipeImageView.image = Images.mealPlaceholder
            recipeImageView.alpha = 0.8
            backgroundImageView.image = nil
            backgroundImageView.backgroundColor = UIColor.customRecipeBackground
            visualEffectView.isHidden = true
        }
    }
    
    @objc private func didTapChooseButton() {
        switch searchType {
        case .apiRecipes:
             recipeCellDelegate?.recipeCellDidSelectRecipe(selectedRecipe)
        case .customRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipe(selectedCustomRecipe)
        case .publicRecipes:
            recipeCellDelegate?.recipeCellDidSelectPublicRecipe(selectedPublicRecipe)
        }
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
    }
    
    @objc private func didTapChosenButton() {
        switch searchType {
        case .apiRecipes:
             recipeCellDelegate?.recipeCellDidSelectRecipe(selectedRecipe)
        case .customRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipe(selectedCustomRecipe)
        case .publicRecipes:
            recipeCellDelegate?.recipeCellDidSelectPublicRecipe(selectedPublicRecipe)
        }
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
    }
    
    @objc private func didTapViewButton() {
        switch searchType {
        case .apiRecipes:
            recipeCellDelegate?.recipeCellDidSelectView(selectedRecipe)
        case .customRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipeView(selectedCustomRecipe)
        case .publicRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipeView(selectedPublicRecipe)
        }
    }
}
