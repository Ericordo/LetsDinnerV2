//
//  EventSummaryViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import EventKit
import ReactiveSwift

protocol EventSummaryViewControllerDelegate: class {
    func eventSummaryVCOpenTasksList()
    func eventSummaryVCDidAnswer(hasAccepted: Invitation)
    func eventSummaryVCOpenEventInfo()
    func eventSummaryVCDidUpdateDate(date: Double)
    func eventSummaryVCDidCancelEvent()
}

private enum RowItemNumber: Int, CaseIterable {
    case invite = 0
    case title = 1
    case answerCell = 2
    case hostInfo = 3
    case dateInfo = 4
    case locationInfo = 5
    case descriptionInfo = 6
    case taskInfo = 7
    case userInfo = 8
}

class EventSummaryViewController: UIViewController {
    // MARK: - Properties
    private let summaryTableView : UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 1)))
        tableView.backgroundColor = .backgroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 33, bottom: 0, right: 0)
        tableView.separatorColor = .cellSeparatorLine
        tableView.isHidden = true
        return tableView
    }()
    
    private let loadingView = LDLoadingView()
    
    #warning("Modify this, a user should not be nil, the way the user is fetched is wrong, you can be a user but not a participant")
    private var user : User? { // User Status should be fetched from here
        if let index = Event.shared.participants.firstIndex (where: { $0.identifier == Event.shared.currentUser?.identifier }) {
            let user = Event.shared.participants[index]
            return user
        } else {
            return nil
        }
    }
    
    private let store = EKEventStore()
    
    private let darkView = UIView()
    
    private let rescheduleView = LDRescheduleView()
    
    private var swipeDownGestureToHideRescheduleView = UISwipeGestureRecognizer()

    weak var delegate: EventSummaryViewControllerDelegate?
    
    private let viewModel : EventSummaryViewModel
    
    init(viewModel: EventSummaryViewModel, delegate: EventSummaryViewControllerDelegate) {
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
        setupTableView()
        configureGestureRecognizers()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StepStatus.currentStep = .eventSummaryVC
    }
    
    private func bindViewModel() {
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
        
        self.viewModel.eventFetchSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeResult { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                LostEventView().show(superView: self.view)
                self.showBasicAlert(title: AlertStrings.oops, message: error.description)
            case.success(()):
                self.updateTable()
            }
        }
        
        self.viewModel.statusUpdateSignal
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeResult { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.showBasicAlert(title: AlertStrings.oops, message: error.description)
            case.success(let status):
                self.delegate?.eventSummaryVCDidAnswer(hasAccepted: status)
            }
        }
    }
    
    private func configureGestureRecognizers() {
        swipeDownGestureToHideRescheduleView = UISwipeGestureRecognizer(target: self,
                                                                        action: #selector(cancelReschedule))
        swipeDownGestureToHideRescheduleView.direction = .down
    }
    
    private func updateTable() {
        #warning("For test only, to delete")
        self.testOverride()
        
        summaryTableView.reloadData()
        summaryTableView.isHidden = false
    }
    
    private func addToCalendarAndAccept() {
        let title = Event.shared.dinnerName
        let date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
        let location = Event.shared.dinnerLocation
        CalendarManager.shared.addEventToCalendar(view: self,
                                           with: title,
                                           forDate: date,
                                           location: location)
        
        self.didTapAccept()
    }
    
    private func setupTableView() {
        summaryTableView.delegate = self
        summaryTableView.dataSource = self
        summaryTableView.registerCells(CellNibs.titleCell,
                                       CellNibs.answerCell,
                                       CellNibs.infoCell,
                                       CellNibs.descriptionCell,
                                       CellNibs.taskSummaryCell,
                                       CellNibs.userCell,
                                       CellNibs.cancelCell)
        summaryTableView.register(AnswerDeclinedCell.self,
                                  forCellReuseIdentifier: AnswerDeclinedCell.reuseID)
        summaryTableView.register(AnswerAcceptedCell.self,
                                  forCellReuseIdentifier: AnswerAcceptedCell.reuseID)
    }
        
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(summaryTableView)
        view.addSubview(rescheduleView)
        addConstraints()
    }
    
    private func addConstraints() {
        summaryTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rescheduleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(rescheduleView.height)
        }
    }
}

//MARK: - Setup TableView

extension EventSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RowItemNumber.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.titleCell) as! TitleCell
        let answerCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.answerCell) as! AnswerCell
        let answerDeclinedCell = tableView.dequeueReusableCell(withIdentifier: AnswerDeclinedCell.reuseID) as! AnswerDeclinedCell
        let answerAcceptedCell = tableView.dequeueReusableCell(withIdentifier: AnswerAcceptedCell.reuseID) as! AnswerAcceptedCell
        let infoCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.infoCell) as! InfoCell
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.descriptionCell) as! DescriptionCell
        let taskSummaryCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskSummaryCell) as! TaskSummaryCell
        let userCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.userCell) as! UserCell
        let cancelCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.cancelCell) as! CancelCell
        
        let separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)

        switch indexPath.row {
        case RowItemNumber.invite.rawValue:
            #warning("Logic here: user is nil if it's not in the list of participants, a pending user can not be in the list of participants, so this code will never be executed")
            
//            if let user = user {
//                if user.hasAccepted == .pending {
//                    answerCell.separatorInset = separatorInset
//                    answerCell.delegate = self
//                    return answerCell
//                }
//        }
            #warning("Modify this, a user should not be nil, the way the user is fetched is wrong")
                if user == nil {
                    answerCell.separatorInset = separatorInset
                    answerCell.delegate = self
                    return answerCell
            }
        case RowItemNumber.title.rawValue:
            titleCell.titleLabel.text = Event.shared.dinnerName
            titleCell.separatorInset = separatorInset
            return titleCell
        case RowItemNumber.answerCell.rawValue:
            // Check the currentUser has accepted or not
            if let user = user {
                if user.identifier == Event.shared.hostIdentifier {
                    cancelCell.delegate = self
                    return cancelCell
                } else if user.hasAccepted == .declined {
                    answerDeclinedCell.delegate = self
                    return answerDeclinedCell
                } else if user.hasAccepted == .accepted {
                    answerAcceptedCell.delegate = self
                    return answerAcceptedCell
                }
            }
            return UITableViewCell()

        case RowItemNumber.hostInfo.rawValue:
            if let user = user {
                switch user.hasAccepted {
                case .accepted:
                    infoCell.titleLabel.text = LabelStrings.eventInfo
                    infoCell.infoLabel.text = Event.shared.hostName + " "
                    infoCell.accessoryType = .disclosureIndicator
                case .declined:
                    infoCell.titleLabel.text = LabelStrings.host
                    infoCell.infoLabel.text = Event.shared.hostName
                case .pending:
                    infoCell.titleLabel.text = LabelStrings.host
                    infoCell.infoLabel.text = Event.shared.hostName
                }
            } else {
                infoCell.titleLabel.text = LabelStrings.host
                infoCell.infoLabel.text = Event.shared.hostName
                infoCell.cellSeparator.isHidden = false
            }
            return infoCell
        case RowItemNumber.dateInfo.rawValue:
            infoCell.titleLabel.text = LabelStrings.date
            infoCell.infoLabel.text = Event.shared.dinnerDate
            return infoCell
        case RowItemNumber.locationInfo.rawValue:
            infoCell.titleLabel.text = LabelStrings.location
            infoCell.infoLabel.text = Event.shared.dinnerLocation
            return infoCell
        case RowItemNumber.descriptionInfo.rawValue:
            descriptionCell.descriptionLabel.text = Event.shared.eventDescription
            return descriptionCell
        case RowItemNumber.taskInfo.rawValue:
            taskSummaryCell.seeAllBeforeCreateEvent.isHidden = true
            taskSummaryCell.delegate = self
            let percentage = Event.shared.calculateTaskCompletionPercentage()
            taskSummaryCell.progressCircle.animate(percentage: percentage)
            return taskSummaryCell
        case RowItemNumber.userInfo.rawValue:
            return userCell
        default:
            break
        }
        return UITableViewCell()
    }
    
    // MARK: - Row Height
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // 3 conditions: accept(/Host) / Neutral / or decline)
        
        // Default Height:
        // title 120
        // answerCell = 120
        // hostInfo, locationInfo, dateInfo = 52
        // taskInfo: 350
        // userInfo: 160
        
        if let user = user {
            
            if user.hasAccepted == .accepted {
                
                // Accept or Host
                switch indexPath.row {
                case RowItemNumber.invite.rawValue:
                    return 0
                case RowItemNumber.answerCell.rawValue:
                     if Event.shared.isCancelled {
                        return 0
                     } else {
                        // if user is Host
                        return user.identifier == Event.shared.hostIdentifier ? 120 : 80
                    }
                case RowItemNumber.title.rawValue:
                    return 120
                case RowItemNumber.hostInfo.rawValue:
                    return 52
                case RowItemNumber.dateInfo.rawValue,
                     RowItemNumber.locationInfo.rawValue,
                     RowItemNumber.descriptionInfo.rawValue:
                    return 0 // Hide Row
//                case RowItemNumber.taskInfo.rawValue:
//                    if Event.shared.tasks.count != 0 {
//                        return 350
//                    } else {
//                        return 100
//                    }
                case RowItemNumber.userInfo.rawValue:
                    return 160
                default:
                    return UITableView.automaticDimension
                }
                
            } else if user.hasAccepted == .declined {
                
                // MARK: Decline Status
                switch indexPath.row {
                case RowItemNumber.invite.rawValue:
                return 0
                case RowItemNumber.answerCell.rawValue:
                     if Event.shared.isCancelled {
                                   return 0
                               } else {
                                   return 80
                               }
                case RowItemNumber.title.rawValue:
                    return 120
                case RowItemNumber.hostInfo.rawValue:
                    return 52
                case RowItemNumber.dateInfo.rawValue,
                     RowItemNumber.locationInfo.rawValue:
                    return 52
                case RowItemNumber.taskInfo.rawValue:
                    return 0
                case RowItemNumber.userInfo.rawValue:
                    return 160
                default:
                    return UITableView.automaticDimension
                }
            }
        }
        
        // MARK: Pending
        switch indexPath.row {
        case RowItemNumber.invite.rawValue:
            return Event.shared.isCancelled ? 0 : 120
        case RowItemNumber.title.rawValue:
            return 120
        case RowItemNumber.answerCell.rawValue:
            return 0
        case RowItemNumber.hostInfo.rawValue:
            return 52
        case RowItemNumber.dateInfo.rawValue,
             RowItemNumber.locationInfo.rawValue:
            return 52
        case RowItemNumber.taskInfo.rawValue:
            return 0
        case RowItemNumber.userInfo.rawValue:
            return 160
        default:
            return UITableView.automaticDimension
        }
    }
    
    // MARK: - Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = user, user.hasAccepted == .accepted else { return }
        if indexPath.row == RowItemNumber.hostInfo.rawValue {
            self.delegate?.eventSummaryVCOpenEventInfo()
        } else if indexPath.row == RowItemNumber.taskInfo.rawValue && !Event.shared.firebaseEventUid.isEmpty {
            delegate?.eventSummaryVCOpenTasksList()
        }
    }
}

// MARK: - AnswerCellDelegate

extension EventSummaryViewController: AnswerCellDelegate {
    func declineInvitation() {
        self.viewModel.updateStatus(.declined)
    }
    
    func didTapAccept() {
        self.viewModel.updateStatus(.accepted)
    }
    
    func addToCalendarAlert() {
        let alert = UIAlertController(title: AlertStrings.addToCalendarAlertTitle,
                                      message: AlertStrings.addToCalendarAlertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: AlertStrings.nope,
                                      style: UIAlertAction.Style.destructive,
                                      handler: { (_) in self.didTapAccept()}))
        alert.addAction(UIAlertAction(title: AlertStrings.add,
                                      style: UIAlertAction.Style.default,
                                      handler: { (_) in self.addToCalendarAndAccept()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func declineEventAlert() {
        let alert = UIAlertController(title: AlertStrings.declineEventAlertTitle,
                                      message: AlertStrings.declineEventAlertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Decline",
//                                      style: UIAlertAction.Style.destructive,
//                                      handler: { (_) in self.didTapDecline()}))
        alert.addAction(UIAlertAction(title: AlertStrings.decline,
                                       style: UIAlertAction.Style.destructive,
                                       handler: { (_) in
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TappedDecline"), object: nil)
        }))
        alert.addAction(UIAlertAction(title: AlertStrings.no,
                                      style: UIAlertAction.Style.cancel,
                                      handler: nil ))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - AnswerDeclined Cell Delegate
extension EventSummaryViewController: AnswerDeclinedCellDelegate {
    func showUpdateDeclinedStatusAlert() {
        let alert = UIAlertController(title: AlertStrings.changedMind,
                                      message: AlertStrings.updateDeclinedStatus,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AlertStrings.cancel,
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: AlertStrings.yes,
                                      style: .default,
                                      handler: { _ in
                                        self.didTapAccept()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - AnswerAccepted Cell Delegate
extension EventSummaryViewController: AnswerAcceptedCellDelegate {
    func showUpdateAcceptedStatusAlert() {
        let alert = UIAlertController(title: AlertStrings.changedMind,
                                      message: AlertStrings.updateAcceptedStatus,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AlertStrings.cancel,
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: AlertStrings.yes,
                                      style: .default,
                                      handler: { _ in
                                        self.declineInvitation()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: - TaskSummary Cell Delegate
extension EventSummaryViewController: TaskSummaryCellDelegate {
    func taskSummaryCellDidTapSeeAll() {
        if let user = user {
            if user.hasAccepted == .accepted {
                delegate?.eventSummaryVCOpenTasksList()
            } else {
                self.showBasicAlert(title: "", message: AlertStrings.userHasDeclinedAlert)
            }
        } else {
            self.showBasicAlert(title: "", message: AlertStrings.acceptInviteAlert)
        }
    }
}

// MARK: - TaskSummary Cell Delegate

extension EventSummaryViewController: CancelCellDelegate {
    
    func postponeEvent() {
        prepareViewForReschedule()
    }
    
    func cancelEvent() {
        let alert = UIAlertController(title: AlertStrings.cancelEventAlertTitle,
                                      message: AlertStrings.cancelEventAlertMessage,
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: AlertStrings.no, style: .cancel)
        let confirm = UIAlertAction(title: AlertStrings.confirm,
                                    style: .destructive) { action in self.delegate?.eventSummaryVCDidCancelEvent() }
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.present(alert, animated: true)
    }
    
    private func prepareViewForReschedule() {
        darkView.frame = self.view.frame
        darkView.backgroundColor = UIColor.backgroundMirroredColor.withAlphaComponent(0.5)
        darkView.alpha = 0.1
        darkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelReschedule)))
        self.view.addSubview(darkView)
        self.view.bringSubviewToFront(rescheduleView)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveLinear,
                       animations: {
            self.darkView.alpha = 0.8
        }) { (_) in
            self.showRescheduleView()
        }
    }
    
    private func showRescheduleView() {
        self.view.addGestureRecognizer(swipeDownGestureToHideRescheduleView)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveLinear,
                       animations: {
                        self.rescheduleView.snp.updateConstraints { make in
                            make.bottom.equalToSuperview().offset(-4)
                        }
                        self.view.layoutIfNeeded()
        }) { (_) in
            self.rescheduleView.updateButton.addTarget(self, action: #selector(self.didConfirmDate), for: .touchUpInside)
        }
    }
    
    @objc private func cancelReschedule() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveLinear,
                       animations: {
                        self.darkView.alpha = 0
                        self.rescheduleView.snp.updateConstraints { make in
                            make.bottom.equalToSuperview().offset(self.rescheduleView.height)
                        }
                        self.view.layoutIfNeeded()
        }) { (_) in
            self.darkView.removeFromSuperview()
            self.rescheduleView.resetDate()
            self.view.removeGestureRecognizer(self.swipeDownGestureToHideRescheduleView)
        }
    }
    
    @objc private func didConfirmDate() {
        delegate?.eventSummaryVCDidUpdateDate(date: rescheduleView.selectedDate)
    }
}

// MARK: Test Control
extension EventSummaryViewController {
    
    fileprivate func testOverride() {
        // MARK: Test Use
        if testManager.isTesting {
            testManager.createHostStatus()
            
            if testManager.isHost == false {
                if let user = user {
                    testManager.createPendingStatus(user: user)
                    
                    if testManager.isStatusPending == false {
                        testManager.createAcceptStatus(user: user)
                    }
                }
            }
        }
    }
}
