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
    func eventSummaryVCDidAnswer(hasAccepted: Bool, controller: EventSummaryViewController)
}

enum RowItemNumber: Int, CaseIterable {
    case title = 0
    case answerCell = 1
    case hostInfo = 2
    case dateInfo = 3
    case locationInfo = 4
    case descriptionInfo = 5
    case taskInfo = 6
    case userInfo = 7
}

class EventSummaryViewController: UIViewController {
    
    @IBOutlet weak var summaryTableView: UITableView!
    
    let store = EKEventStore()
    weak var delegate: EventSummaryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .eventSummaryVC
        summaryTableView.delegate = self
        summaryTableView.dataSource = self
        
        registerCell(CellNibs.titleCell)
        registerCell(CellNibs.answerCell)
        registerCell(CellNibs.infoCell)
        registerCell(CellNibs.descriptionCell)
        registerCell(CellNibs.taskSummaryCell)
        registerCell(CellNibs.userCell)
        registerCell(CellNibs.calendarCell)
        
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: NSNotification.Name("updateTable"), object: nil)
        
        if !Event.shared.participants.isEmpty {
            summaryTableView.isHidden = false
        }
    }
    
    func setupUI() {
        summaryTableView.tableFooterView = UIView()
    }
    
    @objc func updateTable() {
        summaryTableView.reloadData()
        summaryTableView.isHidden = false
    }
    

    private func registerCell(_ nibName: String) {
        summaryTableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
    }
    
    private func isUsertheHost() -> Bool {
        guard let currentUser = Event.shared.currentUser else { return false }
        if Event.shared.participants.contains(where: { $0.identifier == currentUser.identifier
        }) {
            return true
        } else{
            return false
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
        let infoCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.infoCell) as! InfoCell
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.descriptionCell) as! DescriptionCell
        let taskSummaryCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskSummaryCell) as! TaskSummaryCell
        let userCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.userCell) as! UserCell
        let calendarCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.calendarCell) as! CalendarCell
        
        switch indexPath.row {
        case RowItemNumber.title.rawValue:
            titleCell.titleLabel.text = Event.shared.dinnerName
            titleCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return titleCell
            
        case RowItemNumber.answerCell.rawValue:
            guard let currentUser = Event.shared.currentUser else { return UITableViewCell() }
            if Event.shared.participants.contains(where: { $0.identifier == currentUser.identifier
            }) {
                if answerCell.acceptButton != nil && answerCell.declineButton != nil {
                    answerCell.acceptButton.removeFromSuperview()
                    answerCell.declineButton.removeFromSuperview()
                    answerCell.questionLabel.removeFromSuperview()
                }
            }

            answerCell.delegate = self
            return answerCell

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
            
        case RowItemNumber.descriptionInfo.rawValue:
            descriptionCell.descriptionLabel.text = Event.shared.recipeTitles + "\n" + Event.shared.eventDescription
            return descriptionCell
            
        case RowItemNumber.taskInfo.rawValue:
            taskSummaryCell.delegate = self
            var numberOfCompletedTasks = 0
            Event.shared.tasks.forEach { task in
                if task.taskState == .completed {
                    numberOfCompletedTasks += 1
                }
            }
            let percentage = CGFloat(numberOfCompletedTasks)/CGFloat(Event.shared.tasks.count)
            taskSummaryCell.progressCircle.animate(percentage: percentage)
            return taskSummaryCell
        case RowItemNumber.userInfo.rawValue:
            return userCell
        default:
            break
        }
        return UITableViewCell()
    }
    
    // MARK: - Show or hide the row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // 3 conditions: accept(/Host) / Neutral / or decline)
        
        // Default Height:
//        switch indexPath.row {
//        case RowItemNumber.answerCell.rawValue:
//            return 120
//        case RowItemNumber.hostInfo.rawValue:
//            return 52
//        case RowItemNumber.dateInfo.rawValue,
//             RowItemNumber.locationInfo.rawValue:
//            return 52
//        case RowItemNumber.taskInfo.rawValue:
//            return 257
//        case RowItemNumber.userInfo.rawValue:
//            return 150
//        default:
//            return UITableView.automaticDimension
//        }
        
        //Neutral:
        
        if Event.shared.currentUser?.hasAccepted == true {
            // Accept or Host
            
            switch indexPath.row {
            case RowItemNumber.answerCell.rawValue:
                return (isUsertheHost() ? 0 : 120)
            case RowItemNumber.hostInfo.rawValue:
                return 52
            case RowItemNumber.dateInfo.rawValue,
                 RowItemNumber.locationInfo.rawValue:
                return 52
            case RowItemNumber.taskInfo.rawValue:
                return 257
            case RowItemNumber.userInfo.rawValue:
                return 150
            default:
                return UITableView.automaticDimension
            }
            
        } else if Event.shared.currentUser?.hasAccepted == false {
            // Decline
            switch indexPath.row {
            case RowItemNumber.answerCell.rawValue:
                return 120
            case RowItemNumber.hostInfo.rawValue:
                return 52
            case RowItemNumber.dateInfo.rawValue,
                 RowItemNumber.locationInfo.rawValue:
                return 52
            case RowItemNumber.taskInfo.rawValue:
                return 0
            case RowItemNumber.userInfo.rawValue:
                return 150
            default:
                return UITableView.automaticDimension
            }
            
        }
        
        // Netural - Pending
        switch indexPath.row {
        case RowItemNumber.answerCell.rawValue:
            return 120
        case RowItemNumber.hostInfo.rawValue:
            return 52
        case RowItemNumber.dateInfo.rawValue,
             RowItemNumber.locationInfo.rawValue:
            return 52
        case RowItemNumber.taskInfo.rawValue:
            return 0
        case RowItemNumber.userInfo.rawValue:
            return 150
        default:
            return UITableView.automaticDimension
        }
    }
    
    // MARK: - Other Function
    
    func addEventToCalendar(with title: String, forDate eventStartDate: Date, location: String) {
        store.requestAccess(to: .event) { (success, error) in
            if error == nil {
                let event = EKEvent.init(eventStore: self.store)
                event.title = title
                event.calendar = self.store.defaultCalendarForNewEvents
                event.startDate = eventStartDate
                event.endDate = Calendar.current.date(byAdding: .minute, value: 60, to: eventStartDate)
                event.location = location
                let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -3600, since: event.startDate))
                event.addAlarm(alarm)
                let predicate = self.store.predicateForEvents(withStart: eventStartDate, end: Calendar.current.date(byAdding: .minute, value: 60, to: eventStartDate)! , calendars: nil)
                let existingEvents = self.store.events(matching: predicate)
                let eventAlreadyAdded = existingEvents.contains { (existingEvent) -> Bool in
                    existingEvent.title == title && existingEvent.startDate == eventStartDate
                }
                if eventAlreadyAdded {
                    let alert = UIAlertController(title: MessagesToDisplay.eventExists, message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    do {
                        try self.store.save(event, span: .thisEvent)
                        DispatchQueue.main.async {
                            let doneAlert = UIAlertController(title: MessagesToDisplay.calendarAlert, message: "", preferredStyle: .alert)
                            doneAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(doneAlert, animated: true, completion: nil)
                        }
                    } catch let error {
                        print("failed to save event", error)
                    }
                }
            } else {
                print("error = \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    
}

// MARK: - AnswerCellDelegate

extension EventSummaryViewController: AnswerCellDelegate {
    func didTapAccept() {
        delegate?.eventSummaryVCDidAnswer(hasAccepted: true, controller: self)
    }
    
    func didTapDecline() {
        delegate?.eventSummaryVCDidAnswer(hasAccepted: false, controller: self)
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
        alert.addAction(UIAlertAction(title: "Decline",
                                      style: UIAlertAction.Style.destructive,
                                      handler: { (_) in self.didTapDecline()}))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.default,
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
        addEventToCalendar(with: title, forDate: date, location: location)
        
        self.didTapAccept()
    }
}

// MARK: - TaskSummary Cell Delegate

extension EventSummaryViewController: TaskSummaryCellDelegate {
    func taskSummaryCellDidTapSeeAll() {
        if let index = Event.shared.participants.firstIndex (where: { $0.identifier == Event.shared.currentUser?.identifier }) {
            let user = Event.shared.participants[index]
            if user.hasAccepted {
                delegate?.eventSummaryVCOpenTasksList(controller: self)
            } else {
                presentAlert(MessagesToDisplay.declinedInvitation)
            }
        } else {
            presentAlert(MessagesToDisplay.acceptInviteAlert)
        }
    }
    
    func presentAlert(_ title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}
