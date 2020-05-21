//
//  ReviewViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import EventKit
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
        sv.spacing = 32
        return sv
    }()
    
    private let editButton : SecondaryButton = {
        let button = SecondaryButton()
        button.setTitle(LabelStrings.back, for: .normal)
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

    weak var delegate: ReviewViewControllerDelegate?
    
    private let darkView = UIView()
    
    private var isChecking = false
    
    private let store = EKEventStore()
    
    private let loadingView = LDLoadingView()
    
    private let viewModel: ReviewViewModel
    
    // MARK: Init
    init(viewModel: ReviewViewModel) {
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
        StepStatus.currentStep = .reviewVC
    }
    
    // MARK: ViewModel Binding
    private func bindViewModel() {
        editButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.delegate?.reviewVCDidTapPrevious()
        }
        
        sendButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.isChecking ? self.showCalendarAlert() : self.reviewBeforeSending()
        }
        
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
        
        self.viewModel.dataUploadSignal.observe(on: UIScheduler())
            .observeResult { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                #warning("Modify error message")
                #warning("In case of failure, the event will already have been added to the calendar, so there will be a duplicate")
                self.showBasicAlert(title: "Oops!", message: error.localizedDescription)
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
        darkView.frame = self.view.frame
        darkView.backgroundColor = UIColor.backgroundMirroredColor.withAlphaComponent(0.5)
        darkView.alpha = 0.1
        darkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelSending)))
        self.view.addSubview(darkView)
        self.view.bringSubviewToFront(headerView)
        self.headerView.bringSubviewToFront(sendButton)
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
                        self.sendButton.setTitle("Confirm", for: .normal)
                        self.sendButton.setTitleColor(.white, for: .normal)
                        self.sendButton.backgroundColor = Colors.customBlue
        }) { (_) in
            self.isChecking = true
        }
    }
    
    @objc private func cancelSending() {
        self.isChecking = false
        darkView.removeFromSuperview()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.sendButton.snp.removeConstraints()
            self.view.layoutIfNeeded()
            self.sendButton.setTitle("Send", for: .normal)
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
    
    private func showCalendarAlert() {
        let alert = UIAlertController(title: AlertStrings.addToCalendarAlertTitle,
                                      message: AlertStrings.addToCalendarAlertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: AlertStrings.nope,
                                      style: UIAlertAction.Style.destructive,
                                      handler: { (_) in self.viewModel.uploadEvent()}))
        alert.addAction(UIAlertAction(title: AlertStrings.add,
                                      style: UIAlertAction.Style.default,
                                      handler: { (_) in self.addEventToCalendarAndUpload() }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addEventToCalendarAndUpload() {
        let title = Event.shared.dinnerName
        let date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
        let location = Event.shared.dinnerLocation
        
        calendarManager.addEventToCalendar(view: self,
                                           with: title,
                                           forDate: date,
                                           location: location)
        
        self.viewModel.uploadEvent()
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
            make.centerX.equalToSuperview()
            make.width.equalTo(220)
        }
        
        summaryTableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
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


