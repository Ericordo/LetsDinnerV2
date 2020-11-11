//
//  PremiumCheckViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/11/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift

protocol PremiumCheckViewControllerDelegate: class {
    func subscriptionCheckDone(newSubscription: NewSubscription?)
    func subscriptionCheckFailed()
}

class PremiumCheckViewController: LDViewController {
    
    private let logoImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = Images.mealPlaceholder
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()
    
    private let loadingView = LDLoadingView()
    
    private let viewModel : PremiumCheckViewModel
    
    weak var delegate : PremiumCheckViewControllerDelegate?
    
    init(viewModel: PremiumCheckViewModel, delegate: PremiumCheckViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        self.viewModel.checkIfUserIsSubscribed()
    }
    
    private func bindViewModel() {
        self.viewModel.subscribedSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.showFailedVerification(message: error.description)
                case.success():
                    self.delegate?.subscriptionCheckDone(newSubscription: nil)
                }
            }
        
        self.viewModel.newSubscriptionSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.showBasicAlert(title: AlertStrings.oops,
                                        message: error.description)
                case .success(let newSubscription):
                    self.delegate?.subscriptionCheckDone(newSubscription: newSubscription)
                }
            }
        
        self.viewModel.isLoading.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] isLoading in
                if isLoading {
                    self.view.addSubview(self.loadingView)
                    self.loadingView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    self.loadingView.start()
                } else {
                    self.loadingView.stop()
                }
            }
    }
    
    private func showFailedVerification(message: String) {
        let alert = UIAlertController(title: AlertStrings.oops,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: AlertStrings.okAction,
                                   style: .default) { _ in
            self.delegate?.subscriptionCheckFailed()
        }
        alert.addAction(action)
        self.present(alert,
                     animated: true,
                     completion: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(logoImageView)
        addConstraints()
    }
    
    private func addConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(90)
            make.width.equalTo(90)
        }
    }
}
