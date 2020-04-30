//
//  DescriptionCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import SafariServices

class DescriptionCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var recipesCollectionView: UICollectionView!
    
    private let selectedRecipes = Event.shared.selectedRecipes
    private let selectedCustomRecipes = Event.shared.selectedCustomRecipes
    private var allRecipesTitles = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .backgroundColor

        // Initialization code
        self.configureUI()
        self.mergeRecipesTitles()
        
        if selectedRecipes.isEmpty && selectedCustomRecipes.isEmpty {
            recipesCollectionView.removeFromSuperview()
        }
        
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
           descriptionLabel.sizeToFit()
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureUI() {
        self.recipesCollectionView.dataSource = self
        self.recipesCollectionView.delegate = self
        self.recipesCollectionView.register(UINib(nibName: CellNibs.recipeCVCell, bundle: nil), forCellWithReuseIdentifier: CellNibs.recipeCVCell)
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 17)

        self.recipesCollectionView.collectionViewLayout = layout
        
        self.descriptionLabel.backgroundColor = nil
        self.descriptionLabel.textColor = Colors.dullGrey
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRecipesTitles.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recipeCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellNibs.recipeCVCell, for: indexPath) as! RecipeCVCell
        let recipeTitle = allRecipesTitles[indexPath.row]
        recipeCVCell.configureCell(recipeTitle: recipeTitle)
        return recipeCVCell
     }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeName = allRecipesTitles[indexPath.row]
        
        let index = selectedRecipes.firstIndex { recipe -> Bool in
            recipe.title == recipeName
        }
        
        let customIndex = selectedCustomRecipes.firstIndex { customRecipe -> Bool in
            customRecipe.title == recipeName
        }
        
        if let index = index {
            let selectedRecipe = selectedRecipes[index]
            openRecipeInSafari(recipe: selectedRecipe)
        }
        
        if let customIndex = customIndex {
            let selectedCustomRecipe = selectedCustomRecipes[customIndex]
            let customRecipeDetailsVC = CustomRecipeDetailsViewController()
            customRecipeDetailsVC.modalPresentationStyle = .fullScreen
            customRecipeDetailsVC.selectedRecipe = selectedCustomRecipe
            customRecipeDetailsVC.existingEvent = true
            self.window?.rootViewController?.present(customRecipeDetailsVC, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
        
    private func openRecipeInSafari(recipe: Recipe) {
        guard let sourceUrl = recipe.sourceUrl else { return }
        if let url = URL(string: sourceUrl) {
            let vc = CustomSafariVC(url: url)
            self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func mergeRecipesTitles() {
        allRecipesTitles = CustomOrderHelper.shared.mergeAllRecipesTitleInCustomOrder()
        
    }

}
