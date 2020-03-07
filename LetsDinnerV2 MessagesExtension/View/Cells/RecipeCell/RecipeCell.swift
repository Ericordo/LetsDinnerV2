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
    func recipeCellDidSelectRecipe(recipe: Recipe)
    func recipeCellDidSelectCustomRecipe(customRecipe: CustomRecipe)
    func recipeCellDidSelectView(recipe: Recipe)
    func recipeCellDidSelectCustomRecipeView(customRecipe: CustomRecipe)
}

class RecipeCell: UITableViewCell {
    @IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var chosenButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var viewButton: UIButton!
    
    var selectedRecipe = Recipe(dict: [:])
    var selectedCustomRecipe = CustomRecipe()
    var searchType: SearchType = .apiRecipes

    weak var recipeCellDelegate: RecipeCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    

    func setupCell() {
        backgroundCellView.clipsToBounds = true
        backgroundCellView.layer.cornerRadius = 10
        backgroundCellView.backgroundColor = UIColor.secondaryTextLabel
        
        chooseButton.clipsToBounds = true
        chooseButton.layer.cornerRadius = 10
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 10
        recipeNameLabel.sizeToFit()
        recipeImageView.kf.indicatorType = .activity
        selectionStyle = .none
    }
    
    func configureCell(recipe: Recipe, isSelected: Bool, searchType: SearchType) {
        if let imageURL = URL(string: recipe.imageUrl!) {
            recipeImageView.kf.setImage(with: imageURL)
            backgroundImageView.kf.setImage(with: imageURL)
        }
        recipeImageView.isHidden = false
        self.searchType = searchType
        recipeNameLabel.text = recipe.title!
        selectedRecipe = recipe
        chooseButton.isHidden = isSelected
        chosenButton.isHidden = !isSelected
        recipeNameLabel.sizeToFit()
        
        if #available(iOSApplicationExtension 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                let blurEffect = UIBlurEffect(style: .dark)
                self.visualEffectView.effect = blurEffect
            }
        }
    }
    
    func configureCellWithCustomRecipe(customRecipe: CustomRecipe, isSelected: Bool, searchType: SearchType) {
        if let downloadUrl = customRecipe.downloadUrl {
            recipeImageView.kf.setImage(with: URL(string: downloadUrl))
            backgroundImageView.kf.setImage(with: URL(string: downloadUrl))
//        if let imageData = customRecipe.imageData {
//            recipeImageView.image = UIImage(data: imageData)
//            backgroundImageView.image = UIImage(data: imageData)
        } else {
            // For nil Image
            recipeImageView.image = UIImage(named: "mealPlaceholderImage")
            recipeImageView.alpha = 0.8

            backgroundImageView.image = nil
            backgroundImageView.backgroundColor = Colors.paleGray.withAlphaComponent(1.0)

        }
        self.searchType = searchType
        recipeNameLabel.text = customRecipe.title
        selectedCustomRecipe = customRecipe
        chooseButton.isHidden = isSelected
        chosenButton.isHidden = !isSelected
    }
    
    @IBAction func didTapChooseButton(_ sender: UIButton) {
        switch searchType {
        case .apiRecipes:
             recipeCellDelegate?.recipeCellDidSelectRecipe(recipe: selectedRecipe)
        case .customRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipe(customRecipe: selectedCustomRecipe)
        }
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
    }
    
    @IBAction func didTapChosenButton(_ sender: UIButton) {
        switch searchType {
        case .apiRecipes:
             recipeCellDelegate?.recipeCellDidSelectRecipe(recipe: selectedRecipe)
        case .customRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipe(customRecipe: selectedCustomRecipe)
        }
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
    }
    
    @IBAction func didTapViewButton(_ sender: UIButton) {
        switch searchType {
        case .apiRecipes:
            recipeCellDelegate?.recipeCellDidSelectView(recipe: selectedRecipe)
        case .customRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipeView(customRecipe: selectedCustomRecipe)
        }
        
    }
    
    // For TableViewCell Editing
    override func layoutSubviews() {
        super.layoutSubviews()
//        cellActionButtonLabel?.textColor = .activeButton

    }
    
}
