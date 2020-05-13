//
//  FirstTimeRecipeCreationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 13/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class RecipeCreateStartViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
        
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .left
        label.text = "Create your own custom recipes to cook your favourite meals!"
        return label
    }()
    
    private lazy var descriptionLabelOne: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = ""
        return label
    }()
    
    private lazy var descriptionLabelTwo: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = ""
        return label
    }()
    
    private lazy var descriptionLabelThree: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = ""
        return label
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        return stackView
    }()
    
    override func viewDidLoad() {
        self.setupUI()
    }
    
    private func setupUI() {
        
    }
    
    
}
