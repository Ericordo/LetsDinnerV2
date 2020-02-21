//
//  ReviewViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 17/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import EventKit

protocol ReviewViewControllerDelegate: class {
    func reviewVCDidTapPrevious(controller: ReviewViewController)
    func reviewVCDidTapSend(controller: ReviewViewController)
    func reviewVCBackToManagementVC(controller: ReviewViewController)
}

class ReviewViewController: UIViewController {
    
    @IBOutlet weak var editButton: GreyButton!
    @IBOutlet weak var sendButton: GreyButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var summaryTableView: UITableView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var sendButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var topSendingLabel: UILabel!
    
    weak var delegate: ReviewViewControllerDelegate?
    
    let mailImageView : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "mail")
        image.contentMode = .scaleAspectFit
        image.alpha = 0
        return image
    }()
    
    let darkView = UIView()
    var isChecking = false
    let store = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .reviewVC
        summaryTableView.delegate = self
        summaryTableView.dataSource = self
        
        registerCell(CellNibs.titleCell)
        registerCell(CellNibs.infoCell)
        registerCell(CellNibs.descriptionCell)
        registerCell(CellNibs.taskSummaryCell)

        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showUploadFail), name: Notification.Name(rawValue: "UploadError"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.post(name: Notification.Name("didGoToNextStep"), object: nil, userInfo: ["step": 5])
    }

    private func setupUI() {
        summaryTableView.tableFooterView = UIView()
        sendButtonLeadingConstraint.isActive = false
        
        if #available(iOS 13.2, *) {
            topSendingLabel.text = LabelStrings.readyToSend2
        } else {
            topSendingLabel.text = LabelStrings.readyToSend1
        }

    }
    
    private func registerCell(_ nibName: String) {
           summaryTableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
       }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        delegate?.reviewVCDidTapPrevious(controller: self)
    }
    
    @IBAction func didTapSend(_ sender: Any) {
        if isChecking {
            // Show Alert if add to calendar
            addToCalendarAlert()
        } else {
            reviewBeforeSending()
        }
    }
    
    func confirmToAddCalendar() {
        let title = Event.shared.dinnerName
        let date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
        let location = Event.shared.dinnerLocation
        
        calendarManager.addEventToCalendar(view: self,
                                            with: title,
                                            forDate: date,
                                            location: location)
        
        sendInvitation()
    }
    
    func addToCalendarAlert() {
        let alert = UIAlertController(title: MessagesToDisplay.addToCalendarAlertTitle,
                                      message: MessagesToDisplay.addToCalendarAlertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Nope",
                                      style: UIAlertAction.Style.destructive,
                                      handler: { (_) in self.sendInvitation()}))
        alert.addAction(UIAlertAction(title: "Add",
                                      style: UIAlertAction.Style.default,
                                      handler: { (_) in self.confirmToAddCalendar() }))
        self.present(alert, animated: true, completion: nil)
    }
    
//    private func animateSending() {
//        view.addSubview(mailImageView)
//        mailImageView.translatesAutoresizingMaskIntoConstraints = false
//        mailImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        mailImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
//        mailImageView.widthAnchor.constraint(equalToConstant: 105).isActive = true
//        mailImageView.heightAnchor.constraint(equalToConstant: 105).isActive = true
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.summaryTableView.alpha = 0
//            self.mailImageView.alpha = 1
//        }) { (_) in
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.mailImageView.transform = CGAffineTransform(translationX: 0, y: -200)
//                self.mailImageView.alpha = 0
//            }) { (_) in
//                self.delegate?.reviewVCDidTapSend(controller: self)
//            }
//        }
//    }
    
    private func reviewBeforeSending() {
        darkView.frame = self.view.frame
        darkView.backgroundColor = UIColor.textLabel.withAlphaComponent(0.1)
        darkView.alpha = 0
        darkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelSending)))
        self.view.addSubview(darkView)
        self.view.bringSubviewToFront(self.buttonStackView)
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.darkView.alpha = 1
            self.sendButtonLeadingConstraint =  self.sendButton.leadingAnchor.constraint(equalTo: self.buttonStackView.leadingAnchor, constant: 0)
            self.sendButtonLeadingConstraint.isActive = true
            self.view.layoutIfNeeded()
            self.sendButton.setTitle("Confirm", for: .normal)
            self.sendButton.setTitleColor(.white, for: .normal)
            self.sendButton.backgroundColor = Colors.customBlue
        }) { (_) in
            self.isChecking = true
        }
    }
    
    private func sendInvitation() {
        darkView.removeFromSuperview()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.summaryTableView.alpha = 0.65
            self.summaryTableView.transform = CGAffineTransform(translationX: 0, y: 30)
        }) { (_) in
            self.isChecking = false
            self.delegate?.reviewVCDidTapSend(controller: self)
        }
    }
    
    @objc private func cancelSending() {
        self.isChecking = false
        darkView.removeFromSuperview()
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.sendButtonLeadingConstraint.isActive = false
            self.view.layoutIfNeeded()
            self.sendButton.setTitle("Send", for: .normal)
            self.sendButton.setTitleColor(Colors.customBlue, for: .normal)
            self.sendButton.backgroundColor = Colors.paleGray
        })
    }
    
    @objc private func showUploadFail() {
        let alert = UIAlertController(title: "Error", message: "There was a problem uploading your event, please try again", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
 
}

// MARK: - TableViewSetup
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
            var numberOfCompletedTasks = 0
            Event.shared.tasks.forEach { task in
                if task.taskState == .completed {
                    numberOfCompletedTasks += 1
                }
            }
            let percentage : Double = Double(numberOfCompletedTasks)/Double(Event.shared.tasks.count)
            taskSummaryCell.progressCircle.animate(percentage: percentage)
            return taskSummaryCell
        default:
            break
        }
        return UITableViewCell()
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1, 2, 3:
            return 52
        case 5:
            if Event.shared.tasks.count != 0 {
                return 350
            } else {
                return 100
            }
            
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK:- TaskSummary Delegate
extension ReviewViewController: TaskSummaryCellInReviewVCDelegate {
    func taskSummaryDidTapSeeAllBeforeCreateEvent() {
        // Go back to task management
        delegate?.reviewVCBackToManagementVC(controller: self)
    }
}

