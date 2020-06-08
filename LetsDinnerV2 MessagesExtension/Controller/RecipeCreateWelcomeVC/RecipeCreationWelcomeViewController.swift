//
//  FirstTimeRecipeCreationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 13/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class RecipeCreationWelcomeViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imageView.image = Images.recipeBookIcon
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let stackView: UIStackView = {
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
    
    private let descriptionLabelOne: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.startCreateRecipeMessage1
        return label
    }()
    
    private let descriptionLabelTwo: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.startCreateRecipeMessage2
        return label
    }()
    
    private let descriptionLabelThree: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.startCreateRecipeMessage3
        return label
    }()
    
    private let bottomView = UIView()
    
    private let confirmButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(ButtonTitle.letsGo, for: .normal)
        button.addTarget(self, action: #selector(buttonGoDidPress), for: .touchUpInside)
        return button
    }()
    
    private let contentView = UIView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
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
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        
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
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.bottom.equalTo(bottomView.snp.top)
//            make.width.equalTo(315)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
//            make.height.equalTo(600)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.top.equalToSuperview()
//            make.width.equalTo(315)
        }

        // BottomView
        bottomView.snp.makeConstraints { make in
           make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
           make.height.equalTo(80)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomView.snp.top).offset(10)
        }
    }
    
    @objc func buttonGoDidPress(_ sender: UIButton) {
        defaults.set(true, forKey: Keys.createCustomRecipeWelcomeVCVisited)
        self.dismiss(animated: true, completion: nil)
    }
}
