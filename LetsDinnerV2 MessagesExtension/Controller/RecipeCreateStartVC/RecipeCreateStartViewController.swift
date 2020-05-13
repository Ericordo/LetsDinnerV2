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
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle(" " + ButtonTitle.back, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.activeButton, for: .normal)
        button.setImage(Images.chevronLeft, for: .normal)
        button.addTarget(self, action: #selector(buttonBackDidPress), for: .touchUpInside)
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
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
    
    weak var delegate: RecipesCreationWelcomeVCDelegate?
    
    override func viewDidLoad() {
        self.setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .backgroundColor
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabelOne)
        stackView.addArrangedSubview(descriptionLabelTwo)
        stackView.addArrangedSubview(descriptionLabelThree)
        
        self.view.addSubview(navigationBar)
        self.view.addSubview(bottomView)
        self.view.addSubview(scrollView)
        
        bottomView.addSubview(confirmButton)
        navigationBar.addSubview(backButton)
        scrollView.addSubview(stackView)
        
        self.addConstraints()
        
    }
    
    private func addConstraints() {
        
        // Navigtaion Bar
        navigationBar.snp.makeConstraints { make in
           make.leading.trailing.equalToSuperview()
           make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
           make.height.equalTo(44)
        }
        
        backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }
        
        // CenterView
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
           make.top.equalTo(navigationBar.snp.bottom)
           make.bottom.equalTo(bottomView.snp.top)
            make.width.equalTo(315)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(315)
        }
        
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(80)
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
    
    @objc func buttonBackDidPress(_ sender: UIButton) {
        // Back to RecipeVC
        self.dismiss(animated: true, completion: {        self.delegate?.welcomeVCDelegateDidTapBack(self)
        })
        
    }
    
}
