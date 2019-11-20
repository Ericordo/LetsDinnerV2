//
//  EventInfoViewController.swift
//  LetsDinnerV2
//
//  Created by Alex Cheung on 19/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol EventInfoViewControllerDelegate: class {
    func eventInfoVCDidTapBackButton(controller: EventInfoViewController)
}

class EventInfoViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var eventInfoTableView: UITableView!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    
    
    weak var delegate: EventInfoViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .eventInfoVC
        
        eventInfoTableView.delegate = self
        eventInfoTableView.dataSource = self
        
        registerCell(CellNibs.infoCell)
        registerCell(CellNibs.descriptionCell)
        
        setupUI()
    }
    
    func setupUI() {
        eventInfoTableView.tableFooterView = UIView()
    }
    
    private func registerCell(_ nibName: String) {
        eventInfoTableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
    }
    
    

    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.delegate?.eventInfoVCDidTapBackButton(controller: self)
    }
}

extension EventInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let infoCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.infoCell) as! InfoCell
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.descriptionCell) as! DescriptionCell
        
        switch indexPath.row {
        case 0:
            infoCell.titleLabel.text = LabelStrings.host
            infoCell.infoLabel.text = Event.shared.hostName
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
            descriptionCell.descriptionLabel.text = Event.shared.recipeTitles + "\n" + Event.shared.eventDescription
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
