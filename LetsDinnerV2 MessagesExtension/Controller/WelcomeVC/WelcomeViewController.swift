//
//  WelcomeViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 17/03/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SafariServices

class WelcomeViewController: UIViewController {
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.text = LabelStrings.welcome
        return label
    }()
    
    private lazy var policyLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(string: LabelStrings.termsService, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .semibold), NSAttributedString.Key.foregroundColor: Colors.highlightRed]))
        attributedString.append(NSAttributedString(string: " "))
        attributedString.append(NSAttributedString(string: LabelStrings.and, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.textLabel]))
        attributedString.append(NSAttributedString(string: " "))
        attributedString.append(NSAttributedString(string: LabelStrings.policy, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .semibold), NSAttributedString.Key.foregroundColor: Colors.highlightRed]))
        label.attributedText = attributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPolicy))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    private lazy var continueButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: (view.frame.width - 60), height: 50))
        button.layer.masksToBounds = true
        button.backgroundColor = .black
        button.layer.cornerRadius = 14
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        button.setTitle(LabelStrings.letsGo, for: .normal)
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        return button
    }()
    
    private let verticalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var firstHorizontalStackView = createHorizontalStackView(imageName: Images.inviteIcon, title: LabelStrings.createEvents, text: LabelStrings.createEventsDescription)
    
    private lazy var secondHorizontalStackView = createHorizontalStackView(imageName: Images.thingsIcon, title: LabelStrings.recipesAndTasks, text: LabelStrings.recipesAndTasksDescription)
    
    private lazy var thirdHorizontalStackView = createHorizontalStackView(imageName: Images.chatIcon, title: LabelStrings.neverLeave, text: LabelStrings.neverLeaveDescription)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeVC), name: Notification.Name(rawValue: "WillTransition"), object: nil)
    }
    
    @objc private func didTapContinue() {
        defaults.set(true, forKey: Keys.onboardingComplete)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapPolicy() {
        // TODO: - Change url
        let url = URL(string: "https://www.google.com")
        let vc = CustomSafariVC(url: url!)
        self.present(vc, animated: true, completion: nil)
    }
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(titleLabel)
        view.addSubview(policyLabel)
        view.addSubview(continueButton)
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(firstHorizontalStackView)
        verticalStackView.addArrangedSubview(secondHorizontalStackView)
        verticalStackView.addArrangedSubview(thirdHorizontalStackView)
        addConstraints()
    }
    
    private func addConstraints() {
        // TODO: - Fix for small screens
        // TODO: - Fix for iPad
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 88),
            titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -88),
            titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 13),
            titleLabel.heightAnchor.constraint(equalToConstant: 82)
        ])
        
        policyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            policyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            policyLabel.heightAnchor.constraint(equalToConstant: 20),
            policyLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            continueButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: policyLabel.topAnchor, constant: -20)
        ])
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            verticalStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            verticalStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            verticalStackView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -50)
        ])
    }
    
    private func createHorizontalStackView(imageName: String, title: String, text: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        
        let icon = UIImageView(image: UIImage(named: imageName)?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)))
        icon.contentMode = .scaleAspectFit
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 60),
            icon.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let descriptionLabel : LDLabel = {
            let label = LDLabel()
            return label
        }()
        
        descriptionLabel.configureTextForWelcomeScreen(title: title, text: text)
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(descriptionLabel)
        
        return stackView
    }
}
