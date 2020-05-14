//
//  FirstTimeRecipeCreationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 13/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class RecipeCreationWelcomeViewController: UIViewController {
    
    private lazy var navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.recipeBookIcon
        imageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .backgroundColor
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .left
        label.text = LabelStrings.startCreateRecipeTitle
        label.textColor = .textLabel
        return label
    }()
    
    private lazy var descriptionLabelOne: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.startCreateRecipeMessage1
        return label
    }()
    
    private lazy var descriptionLabelTwo: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.startCreateRecipeMessage2
        return label
    }()
    
    private lazy var descriptionLabelThree: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.startCreateRecipeMessage3
        return label
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        return view
    }()
    
    private lazy var confirmButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 253, height: 50))
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 14
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setGradient(colorOne: Colors.peachPink, colorTwo: Colors.highlightRed)
        button.setTitle(ButtonTitle.letsGo, for: .normal)
        button.setTitleColor(Colors.allWhite, for: .normal)
        button.addTarget(self, action: #selector(buttonGoDidPress), for: .touchUpInside)
        return button
    }()
        
    override func viewDidLoad() {
        self.setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .backgroundColor
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabelOne)
        stackView.addArrangedSubview(descriptionLabelTwo)
        stackView.addArrangedSubview(descriptionLabelThree)
        
        self.view.addSubview(imageView)
        self.view.addSubview(bottomView)
        self.view.addSubview(scrollView)
        
        bottomView.addSubview(confirmButton)
        scrollView.addSubview(stackView)
        
        self.addConstraints()
        
    }
    
    private func addConstraints() {
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(30)
            make.height.width.equalTo(60)
        }
        
        // CenterView
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalTo(imageView.snp.bottom).offset(20)
           make.bottom.equalTo(bottomView.snp.top)
            make.width.equalTo(315)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(315)
        }

        // BottomView
        bottomView.snp.makeConstraints { make in
           make.leading.trailing.bottom.equalToSuperview()
           make.height.equalTo(80)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(253)
            make.top.equalTo(bottomView.snp.top).offset(10)
        }
    }
    
    @objc func buttonGoDidPress(_ sender: UIButton) {
        defaults.set(false, forKey: Keys.firstTimeCreateCustomRecipe)
        self.dismiss(animated: true, completion: nil)
    }
}
