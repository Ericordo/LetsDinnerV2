//
//  EventSummaryViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import EventKit

protocol EventSummaryViewControllerDelegate: class {
    func eventSummaryVCOpenTasksList(controller: EventSummaryViewController)
    func eventSummaryVCDidAnswer(hasAccepted: Invitation, controller: EventSummaryViewController)
    func eventSummaryVCOpenEventInfo(controller: EventSummaryViewController)
    func eventSummaryVCDidUpdateDate(date: Double, controller: EventSummaryViewController)
    func eventSummaryVCDidCancelEvent(controller: EventSummaryViewController)
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
    
    @IBOutlet weak var summaryTableView: UITableView!
    
    // MARK: - Variable
    var user: User? { // User Status should be fetched from here
        if let index = Event.shared.participants.firstIndex (where: { $0.identifier == Event.shared.currentUser?.identifier }) {
            let user = Event.shared.participants[index]
            return user
        } else {
            return nil
        }
    }
    let store = EKEventStore()
    let darkView = UIView()
    let rescheduleView = RescheduleView()
    lazy var rescheduleViewBottomConstraint = rescheduleView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 350)
    var selectedDate: Double?
    
    var swipeDownGestureToHideRescheduleView = UISwipeGestureRecognizer()

    weak var delegate: EventSummaryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .eventSummaryVC
        
        self.setupTableView()
        self.registerCells()
        self.configureGestureRecognizers()
            
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: NSNotification.Name("updateTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showDownloadFail), name: Notification.Name(rawValue: "DownloadError"), object: nil)
        
    }
    
    private func configureGestureRecognizers() {
        swipeDownGestureToHideRescheduleView = UISwipeGestureRecognizer(target: self, action: #selector(cancelReschedule))
        swipeDownGestureToHideRescheduleView.direction = .down
    }
    
    @objc func updateTable() {
        // For Test Only
        self.testOverride()

        summaryTableView.reloadData()
        summaryTableView.isHidden = false
    }
    
    @objc private func showDownloadFail() {
        let alert = UIAlertController(title: "Error", message: "There was a problem downloading the info, please try again", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupTableView() {
        summaryTableView.delegate = self
        summaryTableView.dataSource = self
        summaryTableView.tableFooterView = UIView()
        
        if !Event.shared.participants.isEmpty {
            summaryTableView.isHidden = false
        }
    }
    
    func registerCells() {
        func registerCell(_ nibName: String) {
            summaryTableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
        }
        
        registerCell(CellNibs.titleCell)
        registerCell(CellNibs.answerCell)
        registerCell(CellNibs.answerDeclinedCell)
        registerCell(CellNibs.answerAcceptedCell)
        registerCell(CellNibs.infoCell)
        registerCell(CellNibs.descriptionCell)
        registerCell(CellNibs.taskSummaryCell)
        registerCell(CellNibs.userCell)
        registerCell(CellNibs.cancelCell)
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
        let answerDeclinedCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.answerDeclinedCell) as! AnswerDeclinedCell
        let answerAcceptedCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.answerAcceptedCell) as! AnswerAcceptedCell
        let infoCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.infoCell) as! InfoCell
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.descriptionCell) as! DescriptionCell
        let taskSummaryCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskSummaryCell) as! TaskSummaryCell
        let userCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.userCell) as! UserCell
        let cancelCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.cancelCell) as! CancelCell
        
        let separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)


        switch indexPath.row {
        case RowItemNumber.invite.rawValue:
            
            if let user = user {
                if user.hasAccepted == .pending {
                    answerCell.separatorInset = separatorInset
                    answerCell.delegate = self
                    return answerCell
                }
            }
            
        case RowItemNumber.title.rawValue:
            
            titleCell.titleLabel.text = Event.shared.dinnerName
            titleCell.separatorInset = separatorInset
            return titleCell
            
        case RowItemNumber.answerCell.rawValue:
            
            // Check the currentUser has accepted or not
            if let user = user {
                if user.identifier == Event.shared.hostIdentifier {
//                    cancelCell.separatorInset = separatorInset
                    cancelCell.delegate = self
                    return cancelCell
                } else if user.hasAccepted == .declined {
//                    answerDeclinedCell.separatorInset = separatorInset
                    return answerDeclinedCell
                } else if user.hasAccepted == .accepted {
//                    answerAcceptedCell.separatorInset = separatorInset
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
        if indexPath.row == RowItemNumber.hostInfo.rawValue {
            guard let user = user else { return }
            if user.hasAccepted == .accepted {
                self.delegate?.eventSummaryVCOpenEventInfo(controller: self)
            }
        }
        if indexPath.row == RowItemNumber.taskInfo.rawValue && !Event.shared.firebaseEventUid.isEmpty {
            guard let user = user else { return }
            if user.hasAccepted == .accepted {
                delegate?.eventSummaryVCOpenTasksList(controller: self)
            }
        }
    }
    
}

// MARK: - AnswerCellDelegate

extension EventSummaryViewController: AnswerCellDelegate {
    func declineInvitation() {
        Event.shared.statusNeedUpdate = true
        delegate?.eventSummaryVCDidAnswer(hasAccepted: .declined, controller: self)
    }
    
    func didTapAccept() {
        Event.shared.statusNeedUpdate = true
        delegate?.eventSummaryVCDidAnswer(hasAccepted: .accepted, controller: self)
    }
    
    func addToCalendarAlert() {
        let alert = UIAlertController(title: MessagesToDisplay.addToCalendarAlertTitle,
                                      message: MessagesToDisplay.addToCalendarAlertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Nope",
                                      style: UIAlertAction.Style.destructive,
                                      handler: { (_) in self.didTapAccept()}))
        alert.addAction(UIAlertAction(title: "Add",
                                      style: UIAlertAction.Style.default,
                                      handler: { (_) in self.calendarCellDidTapCalendarButton()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func declineEventAlert() {
        let alert = UIAlertController(title: MessagesToDisplay.declineEventAlertTitle,
                                      message: MessagesToDisplay.declineEventAlertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Decline",
//                                      style: UIAlertAction.Style.destructive,
//                                      handler: { (_) in self.didTapDecline()}))
        alert.addAction(UIAlertAction(title: "Decline",
                                       style: UIAlertAction.Style.destructive,
                                       handler: { (_) in
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TappedDecline"), object: nil)
        }))
        alert.addAction(UIAlertAction(title: "No",
                                      style: UIAlertAction.Style.cancel,
                                      handler: nil ))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Calendar Cell Delegate

extension EventSummaryViewController: CalendarCellDelegate {
    func calendarCellDidTapCalendarButton() {
        let title = Event.shared.dinnerName
        let date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
        let location = Event.shared.dinnerLocation
        calendarManager.addEventToCalendar(view: self,
                                           with: title,
                                           forDate: date,
                                           location: location)
        
        self.didTapAccept()
    }
}

// MARK: - TaskSummary Cell Delegate

extension EventSummaryViewController: TaskSummaryCellDelegate {
    func taskSummaryCellDidTapSeeAll() {
        if let user = user {
            if user.hasAccepted == .accepted {
                delegate?.eventSummaryVCOpenTasksList(controller: self)
            } else {
                presentAlert(MessagesToDisplay.declinedInvitation)
            }
        } else {
            presentAlert(MessagesToDisplay.acceptInviteAlert)
        }
    }
    
    func presentAlert(_ title: String) {
        let alert = UIAlertController(title: title,
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - TaskSummary Cell Delegate

extension EventSummaryViewController: CancelCellDelegate {
    
    func postponeEvent() {
        prepareViewForReschedule()
    }
    
    func cancelEvent() {
        let alert = UIAlertController(title: MessagesToDisplay.cancelEventAlertTitle,
                                      message: MessagesToDisplay.cancelEventAlertMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "Confirm", style: .destructive) { action in
            self.delegate?.eventSummaryVCDidCancelEvent(controller: self)
        }
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func prepareViewForReschedule() {
        darkView.frame = self.view.frame
        darkView.backgroundColor = UIColor.backgroundMirroredColor.withAlphaComponent(0.5)
        darkView.alpha = 0.1
        darkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelReschedule)))
        self.view.addSubview(darkView)
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
        view.addSubview(rescheduleView)
        self.view.addGestureRecognizer(swipeDownGestureToHideRescheduleView)

        rescheduleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rescheduleViewBottomConstraint,
            rescheduleView.heightAnchor.constraint(equalToConstant: 390),
            rescheduleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 4),
            rescheduleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:  -4)
        ])
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.rescheduleViewBottomConstraint = self.rescheduleView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
            self.rescheduleViewBottomConstraint.isActive = true
            self.view.layoutIfNeeded()
        }) { (_) in
        }
        rescheduleView.resetPicker()
        rescheduleView.datePicker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)
        rescheduleView.updateButton.addTarget(self, action: #selector(didConfirmDate), for: .touchUpInside)
    }
    
    @objc private func cancelReschedule() {
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.darkView.alpha = 0.1
            self.rescheduleViewBottomConstraint.isActive = false
            self.rescheduleViewBottomConstraint = self.rescheduleView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 390)
            self.rescheduleViewBottomConstraint.isActive = true
            self.view.layoutIfNeeded()
        }) { (_) in
            self.darkView.removeFromSuperview()
            self.rescheduleView.removeFromSuperview()
        }
        
        self.view.removeGestureRecognizer(swipeDownGestureToHideRescheduleView)
    }
    
    @objc private func didSelectDate(sender: UIDatePicker) {
        let selectedDate = sender.date.timeIntervalSince1970
        if selectedDate != Event.shared.dateTimestamp {
            rescheduleView.updateButton.alpha = 1
            rescheduleView.updateButton.isEnabled = true
        } else {
            rescheduleView.updateButton.alpha = 0.5
            rescheduleView.updateButton.isEnabled = false
        }
        self.selectedDate = selectedDate
    }
    
    @objc private func didConfirmDate() {
        guard let selectedDate = selectedDate else { return }
        delegate?.eventSummaryVCDidUpdateDate(date: selectedDate, controller: self)
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
