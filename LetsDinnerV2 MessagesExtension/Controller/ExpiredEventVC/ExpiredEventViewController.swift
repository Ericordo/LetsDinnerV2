//
//  ExpiredEventViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by DiMa on 03/02/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import EventKit

private enum RowItemNumber: Int, CaseIterable {
    case title = 0
    case hostInfo = 1
    case dateInfo = 2
    case locationInfo = 3
    case expiredEventInfo = 4
}

protocol ExpiredEventViewControllerDelegate: class {
    func expiredEventVCDidTapCreateNewEvent(controller : ExpiredEventViewController)
}

class ExpiredEventViewController: UIViewController {
    
    @IBOutlet weak var createNewEventButton: UIButton!
    @IBOutlet weak var expiredEventTableView: UITableView!
    
    // MARKS: - Variable
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
    
    weak var delegate: ExpiredEventViewControllerDelegate?
    
    // BUG: Running two times
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .expiredEventVC
        setupUI()
        
        self.setupTableView()
        self.registerCells()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: NSNotification.Name("updateTable"), object: nil)
        
        if !Event.shared.participants.isEmpty {
            expiredEventTableView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showDownloadFail), name: Notification.Name(rawValue: "DownloadError"), object: nil)
    }
    
    @objc func updateTable() {
        expiredEventTableView.reloadData()
        expiredEventTableView.isHidden = false
    }
    
    @objc private func showDownloadFail() {
        let alert = UIAlertController(title: "Error", message: "There was a problem downloading the info, please try again", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupTableView() {
        expiredEventTableView.delegate = self
        expiredEventTableView.dataSource = self
        expiredEventTableView.tableFooterView = UIView()
    }
    
    func registerCells() {
        func registerCell(_ nibName: String) {
            expiredEventTableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
        }
        
        registerCell(CellNibs.titleCell)
        registerCell(CellNibs.infoCell)
        registerCell(CellNibs.expiredEventCell)
    }
    
     func setupUI() {
            createNewEventButton.layer.masksToBounds = true
            createNewEventButton.alpha = 1
            createNewEventButton.layer.cornerRadius = 12
            createNewEventButton.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        }
    
    
    @IBAction func didTapCreateNewEvent(_ sender: UIButton) {
        delegate?.expiredEventVCDidTapCreateNewEvent(controller: self)
    }
}


extension ExpiredEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RowItemNumber.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.titleCell) as! TitleCell
        let infoCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.infoCell) as! InfoCell
        let expiredEventCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.expiredEventCell) as! ExpiredEventCell
        let separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        
        switch indexPath.row {
        case RowItemNumber.title.rawValue:
            titleCell.titleLabel.text = Event.shared.dinnerName
            titleCell.separatorInset = separatorInset
            return titleCell
            
        case RowItemNumber.hostInfo.rawValue:
            
            if let user = user {
                if user.hasAccepted == .accepted {
                    infoCell.titleLabel.text = LabelStrings.eventInfo
                    infoCell.infoLabel.text = Event.shared.hostName + " "
                } else if user.hasAccepted == .declined {
                    infoCell.titleLabel.text = LabelStrings.host
                    infoCell.infoLabel.text = Event.shared.hostName
                } else if user.hasAccepted == .pending {
                    infoCell.titleLabel.text = LabelStrings.host
                    infoCell.infoLabel.text = Event.shared.hostName
                }
            } else {
                infoCell.titleLabel.text = LabelStrings.host
                infoCell.infoLabel.text = Event.shared.hostName
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
            
        case RowItemNumber.expiredEventInfo.rawValue:
            return expiredEventCell

        default:
            break
        }
        return UITableViewCell()
    }
    
    // MARK: - Row Height
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Netural - Pending
        switch indexPath.row {
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

    // MARK: - Other Function
    
    
}

