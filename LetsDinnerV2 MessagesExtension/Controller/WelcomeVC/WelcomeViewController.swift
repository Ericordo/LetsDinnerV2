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
        attributedString.append(NSAttributedString(string: LabelStrings.termsService, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.activeButton]))
        attributedString.append(NSAttributedString(string: " "))
        attributedString.append(NSAttributedString(string: LabelStrings.and, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.textLabel]))
        attributedString.append(NSAttributedString(string: " "))
        attributedString.append(NSAttributedString(string: LabelStrings.policy, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.activeButton]))
        label.attributedText = attributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPolicy))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    private lazy var continueButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 253, height: 50))
        button.layer.masksToBounds = true
        button.backgroundColor = .black
        button.layer.cornerRadius = 14
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setGradient(colorOne: Colors.peachPink, colorTwo: Colors.highlightRed)
        button.setTitle(ButtonTitle.letsGo, for: .normal)
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
    
    private lazy var firstHorizontalStackView = createHorizontalStackView(image: Images.inviteIcon,
                                                                          title: LabelStrings.createEvents,
                                                                          text: LabelStrings.createEventsDescription)
    
    private lazy var secondHorizontalStackView = createHorizontalStackView(image: Images.thingsIcon,
                                                                           title: LabelStrings.recipesAndTasks,
                                                                           text: LabelStrings.recipesAndTasksDescription)
    
    private lazy var thirdHorizontalStackView = createHorizontalStackView(image: Images.chatIcon,
                                                                          title: LabelStrings.neverLeave,
                                                                          text: LabelStrings.neverLeaveDescription)
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeVC),
                                               name: Notification.Name(rawValue: "WillTransition"),
                                               object: nil)
    }
    
    @objc private func didTapContinue() {
        defaults.set(true, forKey: Keys.onboardingComplete)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapPolicy() {
        #warning("Change url")
        let url = URL(string: "https://twitter.com/letsdinnerapp")
        let vc = CustomSafariVC(url: url!)
        self.present(vc, animated: true, completion: nil)
    }
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(policyLabel)
        view.addSubview(continueButton)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(firstHorizontalStackView)
        verticalStackView.addArrangedSubview(secondHorizontalStackView)
        verticalStackView.addArrangedSubview(thirdHorizontalStackView)
        addConstraints()
    }
    
    private func addConstraints() {
        policyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            policyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            policyLabel.heightAnchor.constraint(equalToConstant: 20),
            policyLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 253),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: policyLabel.topAnchor, constant: -20)
        ])
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20)
        ])
        
        contentView.fillSuperview()
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 500)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 88),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -88),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 13),
            titleLabel.heightAnchor.constraint(equalToConstant: 82)
        ])
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                verticalStackView.widthAnchor.constraint(equalToConstant: 400),
                verticalStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                verticalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
                verticalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30),
            ])
        }
    }
}
