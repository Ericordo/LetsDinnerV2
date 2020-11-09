//
//  PremiumViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/04/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import StoreKit
import ReactiveSwift
import FirebaseAnalytics

protocol PremiumViewControllerDelegate: class {
    func subscribeLater()
    func subscribedSuccessfully()
    func restoredSubscription()
}

class PremiumViewController: UIViewController {
//    private let headerView = UIView()

    private let restoreButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.activeButton, for: .normal)
        button.setTitle(LabelStrings.restorePurchases, for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        return button
    }()
    
//    private let separatorView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .sectionSeparatorLine
//        return view
//    }()
    
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
    
    private let laterButton: UIButton = {
        let button = UIButton()
        button.setTitle(LabelStrings.premiumNoThanks, for: .normal)
        button.setTitleColor(.activeButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        return button
    }()
    
    private let subscribeButton : PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(AlertStrings.subscribe, for: .normal)
        return button
    }()
    
    private let trialLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textLabel
        label.textAlignment = .center
        label.text = LabelStrings.freeTrial
        return label
    }()
    
    private let generalInfoLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryTextLabel
        label.text = LabelStrings.subscriptionInfo
        return label
    }()
    
    private let verticalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    #warning("update this")
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
    
    private let loadingView = LDLoadingView()
    
    weak var delegate : PremiumViewControllerDelegate?
    
    private let viewModel : PremiumViewModel
    
    init(delegate: PremiumViewControllerDelegate, viewModel: PremiumViewModel) {
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
        setupUIWithNewSubscription(viewModel.newSubscription)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        StepStatus.currentStep = .premiumVC
        animateTitle()
    }
    
    private func bindViewModel() {
        laterButton.reactive
            .controlEvents(.touchUpInside)
            .observeValues { _ in
                self.delegate?.subscribeLater()
            }
        
        self.subscribeButton.reactive
            .controlEvents(.touchUpInside)
            .observeValues { _ in
                guard IAPHelper.shared.canMakePayments() else {
                    self.showBasicAlert(title: AlertStrings.oops,
                                        message: IAPError.paymentNotAvailable.description)
                    return
                }
                self.showPurchaseAlert(product: self.viewModel.newSubscription.product)
            }
        
        self.restoreButton.reactive
            .controlEvents(.touchUpInside)
            .observeValues { _ in
                self.viewModel.restorePurchase()
            }
        
        self.viewModel.isLoading.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] isLoading in
                if isLoading {
                    self.loadingView.frame = self.view.frame
                    self.view.addSubview(self.loadingView)
                    self.loadingView.start()
                } else {
                    self.loadingView.stop()
                }
            }

        self.viewModel.subscriptionSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    guard error != .paymentWasCancelled else { return }
                    self.showBasicAlert(title: AlertStrings.oops,
                                        message: error.description)
                case.success():
                    Analytics.logEvent("new_subscription", parameters: nil)
                    self.delegate?.subscribedSuccessfully()
                }
            }
        
        self.viewModel.restoreSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.showBasicAlert(title: AlertStrings.oops,
                                        message: error.description)
                case.success(let restored):
                    if restored {
                        self.delegate?.restoredSubscription()
                    } else {
                        self.showBasicAlert(title: AlertStrings.oops,
                                            message: AlertStrings.nothingToRestore)
                    }
                }
            }
    }
    
    private func animateTitle() {
        UIView.animate(withDuration: 2) {
            self.gradientView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func showPurchaseAlert(product: SKProduct) {
        let alert = UIAlertController(title: product.localizedTitle,
                                      message: product.localizedDescription,
                                      preferredStyle: .alert)
        let purchase = UIAlertAction(title: AlertStrings.subscribe,
                                     style: .default) { _ in
            self.viewModel.subscribe()
        }
        let cancel = UIAlertAction(title: AlertStrings.cancel,
                                   style: .cancel,
                                   handler: nil)
        alert.addAction(purchase)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    private func setupUI() {
        view.backgroundColor = UIColor.backgroundColor
//        view.addSubview(headerView)
//        headerView.addSubview(restoreButton)
//        headerView.addSubview(separatorView)
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(gradientView)
        gradientView.addSubview(proLabel)
        gradientView.mask = proLabel
        view.addSubview(laterButton)
        view.addSubview(restoreButton)
        view.addSubview(subscribeButton)
        view.addSubview(trialLabel)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        contentView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(descriptionLabel)
        verticalStackView.addArrangedSubview(firstHorizontalStackView)
        verticalStackView.addArrangedSubview(secondHorizontalStackView)
        verticalStackView.addArrangedSubview(thirdHorizontalStackView)
        verticalStackView.addArrangedSubview(generalInfoLabel)
        addConstraints()
    }
    
    private func setupUIWithNewSubscription(_ newSubscription: NewSubscription) {
        trialLabel.isHidden = !newSubscription.isTrialEligible
        guard let price = newSubscription.product.localizedPrice else { return }
        subscribeButton.setTitle(String.localizedStringWithFormat(ButtonTitle.subscribeFor, price), for: .normal)
    }
    
    private func addConstraints() {
//        headerView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
//            make.height.equalTo(44)
//        }
        
//        restoreButton.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-17)
//            make.centerY.equalToSuperview()
//        }
//
//        separatorView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
        
        titleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(41)
            make.width.equalTo(260)
        }
        
        laterButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.height.equalTo(20)
            make.height.equalTo(laterButton.titleLabel!.font.lineHeight)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        restoreButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(restoreButton.titleLabel!.font.lineHeight)
            make.bottom.equalTo(laterButton.snp.top).offset(-20)
        }
        
        subscribeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.bottom.equalTo(laterButton.snp.top).offset(-10)
            make.bottom.equalTo(restoreButton.snp.top).offset(-20)
        }
        
        trialLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(trialLabel.font.lineHeight)
            make.bottom.equalTo(subscribeButton.snp.top).offset(-10)
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleStackView.snp.bottom).offset(10)
            make.bottom.equalTo(trialLabel.snp.top).offset(-10)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(600)
            make.width.equalTo(self.view.frame.width)
        }
        
        verticalStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            if UIDevice.current.userInterfaceIdiom == .pad {
                make.width.equalTo(400)
                make.centerX.equalToSuperview()
            } else {
                make.leading.equalToSuperview().offset(30)
                make.trailing.equalToSuperview().offset(-30)
            }
        }
    }
}


