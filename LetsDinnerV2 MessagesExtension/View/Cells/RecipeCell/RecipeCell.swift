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
}

class RecipeCell: UITableViewCell {
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var chosenButton: UIButton!
    
    var selectedRecipe = Recipe(dict: [:])
    weak var recipeCellDelegate: RecipeCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    func setupCell() {
        chooseButton.clipsToBounds = true
        chooseButton.layer.cornerRadius = 10
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 10
        bottomView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        recipeImageView.kf.indicatorType = .activity
        selectionStyle = .none
    }
    
    func configureCell(recipe: Recipe, isSelected: Bool) {
        if let imageURL = URL(string: recipe.imageUrl!) {
            recipeImageView.kf.setImage(with: imageURL)
        }
        recipeNameLabel.text = recipe.title!
        selectedRecipe = recipe
        chooseButton.isHidden = isSelected
        chosenButton.isHidden = !isSelected
    }
    
    @IBAction func didTapChooseButton(_ sender: UIButton) {
        recipeCellDelegate?.recipeCellDidSelectRecipe(recipe: selectedRecipe)
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
    }
    
    @IBAction func didTapChosenButton(_ sender: UIButton) {
        recipeCellDelegate?.recipeCellDidSelectRecipe(recipe: selectedRecipe)
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
    }
    
    
}
