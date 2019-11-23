//
//  DescriptionCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class DescriptionCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var recipesCollectionView: UICollectionView!
    
    private let selectedRecipes = Event.shared.selectedRecipes
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.recipesCollectionView.dataSource = self
        self.recipesCollectionView.delegate = self
        self.recipesCollectionView.register(UINib(nibName: CellNibs.recipeCVCell, bundle: nil), forCellWithReuseIdentifier: CellNibs.recipeCVCell)
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        self.recipesCollectionView.collectionViewLayout = layout
        
        self.descriptionLabel.backgroundColor = nil
        self.descriptionLabel.textColor = Colors.dullGray
        
        if Event.shared.selectedRecipes.count == 0 {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedRecipes.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let recipeCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellNibs.recipeCVCell, for: indexPath) as! RecipeCVCell
         let recipe = selectedRecipes[indexPath.row]
         recipeCVCell.configureCell(recipeTitle: recipe.title ?? "")
         return recipeCVCell
     }
    
}
