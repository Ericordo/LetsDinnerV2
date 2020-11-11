//
//  ThankYouViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by DiMa on 15/04/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol ThankYouViewControllerDelegate: class {
    func thankYouVCdidTapContinue()
}

class ThankYouViewController: LDViewController {
    
    private lazy var confettiView = SAConfettiView(frame: view.bounds)
    
    private let heartIcon : UIImageView = {
        let icon = UIImageView()
        icon.image = Images.heartIcon?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0))
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.text = LabelStrings.thankYou
        return label
    }()
    
    private let descriptionLabelOne: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.thankYouDescriptionPartOne
        return label
    }()
    
    private let descriptionLabelTwo: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.thankYouDescriptionPartTwo
        return label
    }()
    
    private lazy var continueButton : PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(ButtonTitle.letsGo, for: .normal)
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        return button
    }()
    
    private let verticalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        return stackView
    }()
    
    weak var delegate : ThankYouViewControllerDelegate?
    
    init(delegate: ThankYouViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        StepStatus.currentStep = .thankYouVC
        confettiView.startConfetti()
    }
    
    @objc private func didTapContinue() {
        confettiView.stopConfetti()
        self.delegate?.thankYouVCdidTapContinue()
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
            heartIcon.widthAnchor.constraint(equalToConstant: 60),
            heartIcon.heightAnchor.constraint(equalToConstant: 60),
            heartIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            heartIcon.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            titleLabel.bottomAnchor.constraint(equalTo: verticalStackView.topAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 82)
        ])
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            verticalStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            verticalStackView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -141)
        ])
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
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
