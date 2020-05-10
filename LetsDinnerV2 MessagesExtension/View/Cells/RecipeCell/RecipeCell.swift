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
    func recipeCellDidSelectView(_ recipe: Recipe)
    func recipeCellDidSelectCustomRecipeView(_ customRecipe: LDRecipe)
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
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var selectedRecipe = Recipe(dict: [:])
//    var selectedCustomRecipe = CustomRecipe()
    var selectedCustomRecipe = LDRecipe()
    var searchType: SearchType = .apiRecipes

    weak var recipeCellDelegate: RecipeCellDelegate?
    
    // Drag and drop
    weak var reorderControl: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    func setupCell() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        
        backgroundCellView.clipsToBounds = true
        backgroundCellView.layer.cornerRadius = 10
//        backgroundCellView.backgroundColor = UIColor.secondaryTextLabel
        backgroundCellView.backgroundColor = .backgroundColor
        
//        chooseButton.clipsToBounds = true
//        chooseButton.layer.cornerRadius = 10
        
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 10
        recipeNameLabel.sizeToFit()
        recipeImageView.kf.indicatorType = .activity
        
        heightConstraint.constant = 110
        selectionStyle = .none
    }
    
    func configureCell(_ recipe: Recipe) {
        if let imageURL = URL(string: recipe.imageUrl!) {
            recipeImageView.kf.setImage(with: imageURL)
            backgroundImageView.kf.setImage(with: imageURL)
        }
        recipeImageView.isHidden = false
        visualEffectView.isHidden = false

        self.searchType = .apiRecipes
        recipeNameLabel.text = recipe.title!
        selectedRecipe = recipe
        chooseButton.isHidden = recipe.isSelected
        chosenButton.isHidden = !recipe.isSelected
        recipeNameLabel.sizeToFit()

        if #available(iOSApplicationExtension 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                let blurEffect = UIBlurEffect(style: .dark)
                self.visualEffectView.effect = blurEffect
            }
        }
    }
    
//    func configureCellWithCustomRecipe(_ customRecipe: CustomRecipe) {
//        if let downloadUrl = customRecipe.downloadUrl {
//            recipeImageView.kf.setImage(with: URL(string: downloadUrl))
//            backgroundImageView.kf.setImage(with: URL(string: downloadUrl))
//            visualEffectView.isHidden = false
//            if #available(iOSApplicationExtension 13.0, *) {
//                if self.traitCollection.userInterfaceStyle == .dark {
//                    let blurEffect = UIBlurEffect(style: .dark)
//                    self.visualEffectView.effect = blurEffect
//                }
//            }
//        } else {
//            recipeImageView.image = UIImage(named: "mealPlaceholderImage")
//            recipeImageView.alpha = 0.8
//            backgroundImageView.image = nil
//            backgroundImageView.backgroundColor = UIColor.customRecipeBackground
//            visualEffectView.isHidden = true
//        }
//        self.searchType = .customRecipes
//        recipeNameLabel.text = customRecipe.title
//        selectedCustomRecipe = customRecipe
//        chooseButton.isHidden = customRecipe.isSelected
//        chosenButton.isHidden = !customRecipe.isSelected
//    }
    
    func configureCellWithCustomRecipe(_ customRecipe: LDRecipe) {
        if let downloadUrl = customRecipe.downloadUrl {
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
            recipeImageView.image = UIImage(named: "mealPlaceholderImage")
            recipeImageView.alpha = 0.8
            backgroundImageView.image = nil
            backgroundImageView.backgroundColor = UIColor.customRecipeBackground
            visualEffectView.isHidden = true
        }
        self.searchType = .customRecipes
        recipeNameLabel.text = customRecipe.title
        selectedCustomRecipe = customRecipe
        chooseButton.isHidden = customRecipe.isSelected
        chosenButton.isHidden = !customRecipe.isSelected
    }
    
    @IBAction func didTapChooseButton(_ sender: UIButton) {
        switch searchType {
        case .apiRecipes:
             recipeCellDelegate?.recipeCellDidSelectRecipe(selectedRecipe)
        case .customRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipe(selectedCustomRecipe)
        }
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
    }
    
    @IBAction func didTapChosenButton(_ sender: UIButton) {
        switch searchType {
        case .apiRecipes:
             recipeCellDelegate?.recipeCellDidSelectRecipe(selectedRecipe)
        case .customRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipe(selectedCustomRecipe)
        }
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
    }
    
    @IBAction func didTapViewButton(_ sender: UIButton) {
        switch searchType {
        case .apiRecipes:
            recipeCellDelegate?.recipeCellDidSelectView(selectedRecipe)
        case .customRecipes:
            recipeCellDelegate?.recipeCellDidSelectCustomRecipeView(selectedCustomRecipe)
        }
        
    }
}
