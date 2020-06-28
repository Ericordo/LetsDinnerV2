//
//  ReviewViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift

protocol ReviewViewControllerDelegate: class {
    func reviewVCDidTapPrevious()
    func reviewVCDidTapSend()
    func reviewVCBackToManagementVC()
}

class ReviewViewController: UIViewController {
    // MARK: Properties
    private let headerView : UIView = {
        let view = UIView()
        return view
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.2, *) {
            label.text = LabelStrings.readyToSend2
        } else {
            label.text = LabelStrings.readyToSend1
        }
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.textColor = .textLabel
        return label
    }()
    
    private let buttonStackView : UIStackView = {
        let sv = UIStackView()
        sv.alignment = .fill
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 15
        return sv
    }()
    
    private let editButton : SecondaryButton = {
        let button = SecondaryButton()
        button.setTitle(LabelStrings.edit, for: .normal)
        return button
    }()
    
    private let sendButton : SecondaryButton = {
        let button = SecondaryButton()
        button.setTitleColor(.buttonTextBlue, for: .normal)
        button.setTitle(LabelStrings.send, for: .normal)
        return button
    }()
    
    private let separator : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    private let summaryTableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .backgroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 33, bottom: 0, right: 0)
        tableView.separatorColor = .cellSeparatorLine
        return tableView
    }()
    
    private let calendarStackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 40
        return sv
    }()
    
    private let calendarLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.addToCalendar
        label.font = .systemFont(ofSize: 17)
        label.textColor = .textLabel
        return label
    }()
    
    private let calendarSwitch : UISwitch = {
        let control = UISwitch()
        control.onTintColor = .activeButton
        control.isOn = defaults.addToCalendar
        return control
    }()

    weak var delegate: ReviewViewControllerDelegate?
    
    private let darkView = UIView()
    
    private var isChecking = false
    
    private let loadingView = LDLoadingView()
    
    private let viewModel: ReviewViewModel
    
    // MARK: Init
    init(viewModel: ReviewViewModel, delegate: ReviewViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
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
        StepStatus.currentStep = .reviewVC
    }
    
    // MARK: ViewModel Binding
    private func bindViewModel() {
        editButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.delegate?.reviewVCDidTapPrevious()
        }
        
        sendButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.isChecking ? self.viewModel.uploadEvent() : self.reviewBeforeSending()
        }
                
        viewModel.addToCalendar <~ calendarSwitch.reactive.isOnValues
        
        self.viewModel.isLoading.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] isLoading in
                guard let self = self else { return }
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
        
        self.viewModel.addToCalendar.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .filter { $0 }
            .startWithValues { [weak self] _ in
                guard let self = self else { return }
                CalendarManager.shared.requestAccessToCalendarIfNeeded()
                    .observe(on: UIScheduler())
                    .take(duringLifetimeOf: self)
                    .filter { !$0 }
                    .startWithValues { [weak self] _ in
                        guard let self = self else { return }
                        self.calendarSwitch.setOn(false, animated: true)
                        if self.isChecking {
                            self.showBasicAlert(title: AlertStrings.calendarAccess, message: LDError.calendarDenied.description)
                        }
                }
        }
        
        self.viewModel.dataUploadSignal.observe(on: UIScheduler())
            .observeResult { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.showBasicAlert(title: AlertStrings.oops, message: error.description)
            case.success(()):
                self.sendInvitation()
            }
        }
    }
    
    // MARK: Methods
    private func setupTableView() {
        summaryTableView.delegate = self
        summaryTableView.dataSource = self
        summaryTableView.registerCells(CellNibs.titleCell,
                                       CellNibs.infoCell,
                                       CellNibs.descriptionCell,
                                       CellNibs.taskSummaryCell)
    }
    
    private func reviewBeforeSending() {
        darkView.frame = summaryTableView.frame
        darkView.backgroundColor = UIColor.backgroundMirroredColor.withAlphaComponent(0.5)
        darkView.alpha = 0.1
        darkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelSending)))
        self.view.addSubview(darkView)
        self.showCalendarSwitch()
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveLinear,
                       animations: {
                        self.darkView.alpha = 0.8
                        self.sendButton.snp.makeConstraints { make in
                            make.leading.equalTo(self.buttonStackView.snp.leading)
                        }
                        self.view.layoutIfNeeded()
                        self.sendButton.setTitle(AlertStrings.confirm, for: .normal)
                        self.sendButton.setTitleColor(.white, for: .normal)
                        self.sendButton.backgroundColor = Colors.customBlue
        }) { (_) in
            self.isChecking = true
        }
    }
    
    @objc private func cancelSending() {
        self.isChecking = false
        darkView.removeFromSuperview()
        hideCalendarSwitch()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.sendButton.snp.removeConstraints()
            self.view.layoutIfNeeded()
            self.sendButton.setTitle(LabelStrings.send, for: .normal)
            self.sendButton.setTitleColor(Colors.customBlue, for: .normal)
            self.sendButton.backgroundColor = Colors.paleGray
        })
    }
    
    private func sendInvitation() {
        darkView.removeFromSuperview()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.summaryTableView.alpha = 0.65
            self.summaryTableView.transform = CGAffineTransform(translationX: 0, y: 30)
        }) { (_) in
            self.isChecking = false
            self.delegate?.reviewVCDidTapSend()
        }
    }
    
    private func showCalendarSwitch() {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveLinear,
                       animations: {
                        self.calendarStackView.snp.remakeConstraints { make in
                            make.top.equalToSuperview().offset(10)
                            make.centerX.equalToSuperview()
                        }
                        self.topLabel.snp.remakeConstraints { make in
                            make.top.equalToSuperview().offset(10)
                            make.trailing.equalTo(self.headerView.snp.leading).offset(-20)
                        }
                        self.view.layoutIfNeeded()
        }) { (_) in
         
        }
    }
    
    private func hideCalendarSwitch() {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveLinear,
                       animations: {
                        self.calendarStackView.snp.remakeConstraints { make in
                            make.top.equalToSuperview().offset(10)
                            make.leading.equalTo(self.headerView.snp.trailing).offset(20)
                        }
                        self.topLabel.snp.remakeConstraints { make in
                            make.top.equalToSuperview().offset(10)
                            make.leading.equalToSuperview().offset(30)
                            make.trailing.equalToSuperview().offset(-30)
                        }
                        self.view.layoutIfNeeded()
        }) { (_) in
         
        }
    }
    
    private func setupUI() {
        self.view.backgroundColor = .backgroundColor
        view.addSubview(headerView)
        headerView.addSubview(topLabel)
        headerView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(editButton)
        buttonStackView.addArrangedSubview(sendButton)
        headerView.addSubview(separator)
        view.addSubview(summaryTableView)
        calendarStackView.addArrangedSubview(calendarLabel)
        calendarStackView.addArrangedSubview(calendarSwitch)
        headerView.addSubview(calendarStackView)
        addConstraints()
    }
    
    private func addConstraints() {
        headerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(130)
        }
        
        separator.snp.makeConstraints { make in
            make.bottom.trailing.leading.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(42)
        }
        
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        summaryTableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }

        calendarStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(headerView.snp.trailing).offset(20)
            
        }
    }
}
    // MARK: TableView Delegate
extension ReviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.titleCell) as! TitleCell
        let infoCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.infoCell) as! InfoCell
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.descriptionCell) as! DescriptionCell
        let taskSummaryCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskSummaryCell) as! TaskSummaryCell
        
        switch indexPath.row {
        case 0:
            titleCell.titleLabel.text = Event.shared.dinnerName
            titleCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return titleCell
        case 1:
            infoCell.titleLabel.text = LabelStrings.host
            infoCell.infoLabel.text = Event.shared.hostName
            infoCell.cellSeparator.isHidden = false
            return infoCell
        case 2:
            infoCell.titleLabel.text = LabelStrings.date
            infoCell.infoLabel.text = Event.shared.dinnerDate
            return infoCell
        case 3:
            infoCell.titleLabel.text = LabelStrings.location
            infoCell.infoLabel.text = Event.shared.dinnerLocation
            return infoCell
        case 4:
            descriptionCell.descriptionLabel.text = Event.shared.eventDescription
            return descriptionCell
        case 5:
            taskSummaryCell.seeAllButton.isHidden = true
            taskSummaryCell.reviewVCDelegate = self
            let percentage = Event.shared.calculateTaskCompletionPercentage()
            taskSummaryCell.progressCircle.animate(percentage: percentage)
            return taskSummaryCell
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 120
        case 1, 2, 3:
            return 52
        default:
            return UITableView.automaticDimension
        }
    }
}

    // MARK: TaskSummary Delegate
extension ReviewViewController: TaskSummaryCellInReviewVCDelegate {
    func taskSummaryDidTapSeeAllBeforeCreateEvent() {
        delegate?.reviewVCBackToManagementVC()
    }
}


