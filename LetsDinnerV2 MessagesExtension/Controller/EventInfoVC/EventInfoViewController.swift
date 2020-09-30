//
//  EventInfoViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 21/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import PDFKit
import ReactiveSwift

protocol EventInfoViewControllerDelegate: class {
    func eventInfoVCDidTapBackButton()
}

class EventInfoViewController: LDNavigationViewController {
    
    private lazy var manualButton : PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(LabelStrings.cookingManual, for: .normal)
        button.addTarget(self, action: #selector(didTapManualButton), for: .touchUpInside)
        button.isHidden = Event.shared.selectedRecipes.count + Event.shared.selectedCustomRecipes.count == 0
        return button
    }()
    
    private let header = UIView()
    
    private let separator : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.eventInfoLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryTextLabel
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
    
    private lazy var reminderButton : SecondaryButton = {
        let button = SecondaryButton()
        button.setTitle(LabelStrings.reminders, for: .normal)
        button.addTarget(self, action: #selector(didTapRemindersButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var calendarButton : SecondaryButton = {
        let button = SecondaryButton()
        button.setTitle(LabelStrings.calendar, for: .normal)
        button.addTarget(self, action: #selector(didTapCalendarButton), for: .touchUpInside)
        return button
    }()
    
    private let infoTableView : UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 1)))
        tableView.backgroundColor = .backgroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 33, bottom: 0, right: 0)
        tableView.separatorColor = .cellSeparatorLine
        return tableView
    }()
    
    weak var delegate: EventInfoViewControllerDelegate?
    
    init(delegate: EventInfoViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StepStatus.currentStep = .eventInfoVC
    }
    
    @objc private func didTapBack() {
        self.delegate?.eventInfoVCDidTapBackButton()
    }
    
    @objc private func didTapRemindersButton() {
        ReminderManager.shared.requestAccessToRemindersIfNeeded()
        .observe(on: UIScheduler())
        .take(duringLifetimeOf: self)
            .startWithValues { [weak self] approval in
                guard let self = self else { return }
                if approval {
                    ReminderManager.shared.addToReminder(on: self)
                } else {
                    self.showBasicAlert(title: AlertStrings.remindersAccess,
                                        message: LDError.remindersDenied.description)
                }
        }
    }
    
    @objc private func didTapCalendarButton() {
        CalendarManager.shared.requestAccessToCalendarIfNeeded()
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [weak self] approval in
                guard let self = self else { return }
                if approval {
                    let title = Event.shared.dinnerName
                    let date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
                    let location = Event.shared.dinnerLocation
                    CalendarManager.shared.addEventToCalendar(on: self,
                                                              with: title,
                                                              forDate: date,
                                                              location: location)
                } else {
                    self.showBasicAlert(title: AlertStrings.calendarAccess,
                                        message: LDError.calendarDenied.description)
                }
        }
    }
    
    @objc private func didTapManualButton() {
        let pdfCreator = PDFCreator()
        let data = pdfCreator.createBook()
        let recipeBook = RecipeBookViewController(documentData: data)
        self.present(recipeBook, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        infoTableView.delegate = self
        infoTableView.dataSource = self
        infoTableView.register(DescriptionCell.self,
                               forCellReuseIdentifier: DescriptionCell.reuseID)
        infoTableView.register(InfoCell.self,
                               forCellReuseIdentifier: InfoCell.reuseID)
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        progressViewContainer.isHidden = true
        navigationBar.nextButton.isHidden = true
        navigationBar.titleLabel.text = LabelStrings.eventInfo
        navigationBar.previousButton.setImage(Images.chevronLeft, for: .normal)
        navigationBar.previousButton.setTitle(LabelStrings.back, for: .normal)
        navigationBar.previousButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
//        view.addSwipeGestureRecognizer(action: { self.delegate?.eventInfoVCDidTapBackButton() })
        view.addSubview(manualButton)
        view.addSubview(header)
        header.addSubview(separator)
        header.addSubview(titleLabel)
        header.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(reminderButton)
        buttonStackView.addArrangedSubview(calendarButton)
        view.addSubview(infoTableView)
        addConstraints()
    }
    
    private func addConstraints() {
        manualButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        header.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(130)
        }
        
        separator.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(42)
        }
        
        infoTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(header.snp.bottom)
            make.bottom.equalTo(manualButton.snp.top).offset(-10)
        }
    }
}

extension EventInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let infoCell = tableView.dequeueReusableCell(withIdentifier: InfoCell.reuseID) as! InfoCell
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: DescriptionCell.reuseID) as! DescriptionCell
        switch indexPath.row {
        case 0:
            infoCell.titleLabel.text = LabelStrings.host
            infoCell.infoLabel.text = Event.shared.hostName
            infoCell.cellSeparator.isHidden = false
            return infoCell
        case 1:
            infoCell.titleLabel.text = LabelStrings.date
            infoCell.infoLabel.text = Event.shared.dinnerDate
            return infoCell
        case 2:
            infoCell.titleLabel.text = LabelStrings.location
            infoCell.infoLabel.text = Event.shared.dinnerLocation
            return infoCell
        case 3:
            descriptionCell.descriptionLabel.text = Event.shared.eventDescription
            return descriptionCell
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0,1,2:
            return 52
        default:
            return UITableView.automaticDimension
        }
    }
}
