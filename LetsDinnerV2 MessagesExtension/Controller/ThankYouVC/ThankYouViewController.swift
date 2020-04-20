//
//  ThankYouViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by DiMa on 15/04/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SafariServices

class ThankYouViewController: UIViewController {
    
    private lazy var confettiView = SAConfettiView(frame: view.bounds)
    
    private let heartIcon : UIImageView = {
        
        let icon = UIImageView(image: UIImage(named: Images.heartIcon)!.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)))
        icon.contentMode = .scaleAspectFit
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 60),
            icon.heightAnchor.constraint(equalToConstant: 60)
        ])
        
//        icon.layer.borderWidth = 1
//        icon.layer.borderColor = UIColor.blue.cgColor
        return icon
    }()
    
    
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.text = LabelStrings.thankYou
//        label.layer.borderWidth = 1
//        label.layer.borderColor = UIColor.blue.cgColor
        return label
    }()
    
    private let descriptionLabelOne: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.thankYouDescriptionPartOne
//        label.layer.borderWidth = 1
//        label.layer.borderColor = UIColor.blue.cgColor
        return label
    }()
    
    private let descriptionLabelTwo: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.thankYouDescriptionPartTwo
//        label.layer.borderWidth = 1
//        label.layer.borderColor = UIColor.blue.cgColor
        return label
    }()
    
    private lazy var continueButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 253, height: 50))
        button.layer.masksToBounds = true
        button.backgroundColor = .black
        button.layer.cornerRadius = 14
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setGradient(colorOne: Colors.peachPink, colorTwo: Colors.highlightRed)
        button.setTitle(LabelStrings.letsGo, for: .normal)
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.blue.cgColor
        return button
    }()
    
    private let verticalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
//        stackView.layer.borderWidth = 1
//        stackView.layer.borderColor = UIColor.blue.cgColor
        return stackView
    }()
    
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
    }
    
    @objc private func didTapContinue() {
        print("tap")
        defaults.set(true, forKey: Keys.onboardingComplete)
        confettiView.startConfetti()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(confettiView)
        view.addSubview(continueButton)
        view.addSubview(heartIcon)
        view.addSubview(titleLabel)
        view.addSubview(verticalStackView)

        verticalStackView.addArrangedSubview(descriptionLabelOne)
        verticalStackView.addArrangedSubview(descriptionLabelTwo)
        addConstraints()
    }
    
    private func addConstraints() {
        
        heartIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heartIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            titleLabel.topAnchor.constraint(equalTo: heartIcon.bottomAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 82)
        ])
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            verticalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -241)
        ])
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 253),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                verticalStackView.widthAnchor.constraint(equalToConstant: 400),
                verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            ])
        }
    }
    
}
