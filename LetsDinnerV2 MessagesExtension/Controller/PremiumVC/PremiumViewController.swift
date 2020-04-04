//
//  PremiumViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/04/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class PremiumViewController: UIViewController {
    
    private let headerView = UIView()
    
    private lazy var confettiView = SAConfettiView(frame: view.bounds)
    
    private let restoreButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.activeButton, for: .normal)
        button.setTitle(LabelStrings.restore, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    private let titleStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        return sv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .textLabel
        label.text = LabelStrings.premiumAppName
        return label
    }()
    
    private let proLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 66, height: 41)))
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.text = LabelStrings.premiumPro
        return label
    }()
    
    private let gradientView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 66, height: 41)))
        let gradient = CAGradientLayer()
        gradient.colors = [Colors.peachPink.cgColor, Colors.highlightRed.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = view.bounds
        view.alpha = 0
        view.layer.addSublayer(gradient)
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.premiumDescription
        return label
    }()
    
    private lazy var laterButton: UIButton = {
        let button = UIButton()
        button.setTitle(LabelStrings.premiumNoThanks, for: .normal)
        button.setTitleColor(.activeButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.addTarget(self, action: #selector(didTapLater), for: .touchUpInside)
        return button
    }()
    
    private lazy var subscribeButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 253, height: 50))
        button.layer.masksToBounds = true
        button.backgroundColor = .black
        button.layer.cornerRadius = 14
        button.titleLabel!.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setGradient(colorOne: Colors.peachPink, colorTwo: Colors.highlightRed)
        button.setTitle(LabelStrings.premiumSubscribe, for: .normal)
        button.addTarget(self, action: #selector(didTapSubscribe), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateTitle()
    }
    
    @objc private func didTapSubscribe() {
        confettiView.startConfetti()
    }
    
    @objc private func didTapLater() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func animateTitle() {
        UIView.animate(withDuration: 2) {
            self.gradientView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor.backgroundColor
        view.addSubview(confettiView)
        view.addSubview(headerView)
        headerView.addSubview(restoreButton)
        headerView.addSubview(separatorView)
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(gradientView)
        gradientView.addSubview(proLabel)
        gradientView.mask = proLabel
        view.addSubview(descriptionLabel)
        view.addSubview(laterButton)
        view.addSubview(subscribeButton)
        addConstraints()
    }
    
    private func addConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restoreButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -17),
            restoreButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            titleStackView.heightAnchor.constraint(equalToConstant: 41),
            titleStackView.widthAnchor.constraint(equalToConstant: 260)
        ])
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            descriptionLabel.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 10),
        ])
        
        laterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            laterButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            laterButton.heightAnchor.constraint(equalToConstant: 20),
            laterButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subscribeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            subscribeButton.widthAnchor.constraint(equalToConstant: 253),
            subscribeButton.heightAnchor.constraint(equalToConstant: 50),
            subscribeButton.bottomAnchor.constraint(equalTo: laterButton.topAnchor, constant: -20)
        ])
    }
}
