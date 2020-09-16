//
//  DescriptionCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import SafariServices

class DescriptionCell: UITableViewCell {
    
    static let reuseID = "DescriptionCell"
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .textLabel
        label.text = LabelStrings.whatsThePlan
        return label
    }()
    
    let descriptionLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private let recipesCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 17)
        layout.minimumLineSpacing = 20
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .backgroundColor
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let selectedRecipes = Event.shared.selectedRecipes
    private let selectedCustomRecipes = Event.shared.selectedCustomRecipes
    private var allRecipesTitles = [String]()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
        self.setupCollectionView()
        if selectedRecipes.isEmpty && selectedCustomRecipes.isEmpty {
            recipesCollectionView.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        self.recipesCollectionView.dataSource = self
        self.recipesCollectionView.delegate = self
        self.recipesCollectionView.register(RecipeCVCell.self,
                                            forCellWithReuseIdentifier: RecipeCVCell.reuseID)
    }
    
    private func setupUI() {
        self.backgroundColor = .backgroundColor
        self.mergeRecipeTitles()
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(recipesCollectionView)
        self.contentView.addSubview(descriptionLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(30)
        }
        
        recipesCollectionView.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-20)
            make.top.equalTo(recipesCollectionView.snp.bottom).offset(20)
            make.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(15)
        }
    }
}

extension DescriptionCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRecipesTitles.count
     }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recipeCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCVCell.reuseID, for: indexPath) as! RecipeCVCell
        let recipeTitle = allRecipesTitles[indexPath.row]
        recipeCVCell.configureCell(recipeTitle: recipeTitle)
        return recipeCVCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeName = allRecipesTitles[indexPath.row]
        let index = selectedRecipes.firstIndex { $0.title == recipeName }
        let customIndex = selectedCustomRecipes.firstIndex { $0.title == recipeName }
        if let index = index {
            let selectedRecipe = selectedRecipes[index]
            openRecipeInSafari(recipe: selectedRecipe)
        }
        if let customIndex = customIndex {
            let selectedCustomRecipe = selectedCustomRecipes[customIndex]
            let viewCustomRecipeVC = RecipeCreationViewController(viewModel: RecipeCreationViewModel(with: selectedCustomRecipe,
                                                                                                     creationMode: false),
                                                                  delegate: nil)
            viewCustomRecipeVC.modalPresentationStyle = .overFullScreen
            self.window?.rootViewController?.present(viewCustomRecipeVC,
                                                     animated: true,
                                                     completion: nil)
        }
    }
}


// MARK: Helper
extension DescriptionCell {
    private func openRecipeInSafari(recipe: Recipe) {
        guard let sourceUrl = recipe.sourceUrl else { return }
        if let url = URL(string: sourceUrl) {
            let vc = CustomSafariVC(url: url)
            self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    private func mergeRecipeTitles() {
        allRecipesTitles = CustomOrderHelper.shared.mergeAllRecipeTitlesInCustomOrder()
    }
}
