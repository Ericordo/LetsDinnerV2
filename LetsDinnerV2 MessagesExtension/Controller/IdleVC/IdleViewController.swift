//
//  IdleViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 22/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol IdleViewControllerDelegate: class {
    func idleVCDidTapContinue()
    func idleVCDidTapNewDinner()
    func idleVCDidTapProfileButton()
}

class IdleViewController: UIViewController {
    
    private lazy var settingsButton : UIButton = {
        let button = UIButton()
        button.setImage(Images.settings, for: .normal)
        button.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
        return button
    }()
    
    private let logo : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = Images.logo
        return iv
    }()
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.letsdinner
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let subtitleLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.letsdinnerSubtitle
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let buttonStackView : UIStackView = {
        let sv = UIStackView()
        sv.spacing = 30
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var eventButton : UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.setTitle(LabelStrings.newEvent, for: .normal)
        button.setTitleColor(.activeButton, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(didTapNewEvent), for: .touchUpInside)
        return button
    }()
    
    private lazy var continueButton : UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.setTitle(LabelStrings.continueButton, for: .normal)
        button.setTitleColor(.activeButton, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: IdleViewControllerDelegate?
    
    init(delegate: IdleViewControllerDelegate) {
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
    
    override func viewDidLayoutSubviews() {
        let gradientLayers = view.layer.sublayers?.compactMap { $0 as? CAGradientLayer }
        gradientLayers?.first?.frame = view.bounds
    }
    
    @objc private func didTapSettings() {
        delegate?.idleVCDidTapProfileButton()
    }
    
    @objc private func didTapNewEvent() {
        delegate?.idleVCDidTapNewDinner()
    }
    
    @objc private func didTapContinue() {
        delegate?.idleVCDidTapContinue()
    }
    
    private func setupUI() {
        view.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        view.addSubview(settingsButton)
        view.addSubview(logo)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(continueButton)
        buttonStackView.addArrangedSubview(eventButton)
        addConstraints()
    }
    
    private func addConstraints() {
        settingsButton.snp.makeConstraints { make in
            make.width.height.equalTo(34)
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        logo.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(55)
            make.centerX.equalToSuperview()
            make.width.equalTo(47)
            make.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.top.equalTo(logo.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        continueButton.snp.makeConstraints { make in
            make.width.equalTo(134)
        }
        
        eventButton.snp.makeConstraints { make in
            make.width.equalTo(134)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(34)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(14)
        }
    }
}
