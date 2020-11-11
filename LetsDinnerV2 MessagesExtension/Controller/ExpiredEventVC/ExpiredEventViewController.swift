//
//  ExpiredEventViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 19/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift

private enum RowItemNumber: Int, CaseIterable {
    case title = 0
    case hostInfo = 1
    case dateInfo = 2
    case locationInfo = 3
    case expiredEventInfo = 4
}

protocol ExpiredEventViewControllerDelegate: class {
    func didTapNewEvent(newSubscription: NewSubscription?)
}

class ExpiredEventViewController: LDViewController {
    // MARK: Properties
    private lazy var newEventButton : PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(LabelStrings.createNewEvent, for: .normal)
        return button
    }()
    
    private let expiredEventTableView : UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 1)))
        tableView.backgroundColor = .backgroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 33, bottom: 0, right: 0)
        tableView.separatorColor = .cellSeparatorLine
        return tableView
    }()
    
    private let loadingView = LDLoadingView()
    
    private let viewModel : PremiumCheckViewModel
    
    weak var delegate: ExpiredEventViewControllerDelegate?
    
    // MARK: Init
    init(delegate: ExpiredEventViewControllerDelegate, viewModel: PremiumCheckViewModel) {
        self.delegate = delegate
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StepStatus.currentStep = .expiredEventVC
    }
    
    private func bindViewModel() {
        self.newEventButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.viewModel.checkIfUserIsSubscribed()
        }
        
        self.viewModel.subscribedSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.showBasicAlert(title: AlertStrings.oops,
                                        message: error.description)
                case.success():
                    self.delegate?.didTapNewEvent(newSubscription: nil)
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
                    self.delegate?.didTapNewEvent(newSubscription: newSubscription)
                }
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
    }
    
    // MARK: Methods
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(newEventButton)
        view.addSubview(expiredEventTableView)
        addConstraints()
    }
    
    private func setupTableView() {
        expiredEventTableView.delegate = self
        expiredEventTableView.dataSource = self
        expiredEventTableView.register(InfoCell.self,
                                        forCellReuseIdentifier: InfoCell.reuseID)
        expiredEventTableView.register(TitleCell.self,
                                       forCellReuseIdentifier: TitleCell.reuseID)
        expiredEventTableView.register(ExpiredEventCell.self,
                                       forCellReuseIdentifier: ExpiredEventCell.reuseID)
    }
    
    private func addConstraints() {
        newEventButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        expiredEventTableView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(newEventButton.snp.top).offset(-10)
        }
    }
}

    // MARK: TableView Delegate
extension ExpiredEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RowItemNumber.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleCell = tableView.dequeueReusableCell(withIdentifier: TitleCell.reuseID) as! TitleCell
        let infoCell = tableView.dequeueReusableCell(withIdentifier: InfoCell.reuseID) as! InfoCell
        let expiredEventCell = tableView.dequeueReusableCell(withIdentifier: ExpiredEventCell.reuseID) as! ExpiredEventCell
     
        switch indexPath.row {
        case RowItemNumber.title.rawValue:
            titleCell.titleLabel.text = Event.shared.dinnerName
            return titleCell
        case RowItemNumber.hostInfo.rawValue:
            infoCell.titleLabel.text = LabelStrings.host
            infoCell.infoLabel.text = Event.shared.hostName
            return infoCell
        case RowItemNumber.dateInfo.rawValue:
            infoCell.titleLabel.text = LabelStrings.date
            infoCell.infoLabel.text = Event.shared.dinnerDate
            return infoCell
        case RowItemNumber.locationInfo.rawValue:
            infoCell.titleLabel.text = LabelStrings.location
            infoCell.infoLabel.text = Event.shared.dinnerLocation
            return infoCell
        case RowItemNumber.expiredEventInfo.rawValue:
            return expiredEventCell
        default:
            break
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case RowItemNumber.title.rawValue:
            return 120
        case RowItemNumber.hostInfo.rawValue,
             RowItemNumber.dateInfo.rawValue,
             RowItemNumber.locationInfo.rawValue:
            return 52
        case RowItemNumber.expiredEventInfo.rawValue:
            return 205
        default:
            return UITableView.automaticDimension
        }
    }
}
