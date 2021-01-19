//
//  TaskCVCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class TaskCVCell: UICollectionViewCell {
    
    static let reuseID = "TaskCVCell"
    
    private let taskStatusButton = TaskStatusButton()
    
    private let taskNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let personLabel = TaskPersonLabel()
    
    private let separatorLine : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    var task: Task?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(task: Task, count: Int) {
        self.isUserInteractionEnabled = true
        self.task = task
        if let amount = task.amount {
            if amount.truncatingRemainder(dividingBy: 1) == 0.0 {
                if let unit = task.unit {
                    taskNameLabel.text = "\(task.name), \(String(format:"%.0f", amount)) \(unit)"
                } else {
                    taskNameLabel.text = "\(task.name), \(String(format:"%.0f", amount))"
                }
            } else {
                if let unit = task.unit {
                    taskNameLabel.text = "\(task.name), \(String(format:"%.1f", amount)) \(unit)"
                } else {
                    taskNameLabel.text = "\(task.name), \(String(format:"%.1f", amount))"
                }
            }
        } else {
            taskNameLabel.text = task.name
        }
        taskStatusButton.setState(state: task.state)
        
        if task.state == .assigned || task.state == .completed {
            if Event.shared.currentUser?.identifier != task.ownerId {
                personLabel.text = task.ownerName
                personLabel.setTextAttributes(userOwnsTask: false)
                taskStatusButton.setColorAttributes(ownedByUser: false, taskState: task.state)
            } else {
                // My Task
                if task.state == .completed {
                    personLabel.text = AlertStrings.completed
                } else {
                    personLabel.text = AlertStrings.assignedToMyself
                }
                personLabel.setTextAttributes(userOwnsTask: true)
                taskStatusButton.setColorAttributes(ownedByUser: true, taskState: task.state)
            }
        } else {
            // Task Not Assigned
            personLabel.text = AlertStrings.noAssignment
            personLabel.setTextAttributes(userOwnsTask: false)
        }
        // For deleting the line for the bottom last cell
        separatorLine.isHidden = false
        if count % 3 == 0 {
            separatorLine.isHidden = true
        }
    }
        
    private func setupUI() {
        self.backgroundColor = .backgroundColor
        contentView.addSubview(taskStatusButton)
        contentView.addSubview(taskNameLabel)
        contentView.addSubview(personLabel)
        contentView.addSubview(separatorLine)
        addConstraints()
    }
    
    private func addConstraints() {
        taskStatusButton.snp.makeConstraints { make in
            make.height.width.equalTo(22)
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(6)
        }
        
        taskNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(taskStatusButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-5)
            make.centerY.equalTo(taskStatusButton)
        }
        
        personLabel.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalTo(taskNameLabel)
        }
    
        separatorLine.snp.makeConstraints { make in
            make.leading.equalTo(taskNameLabel)
            make.trailing.equalToSuperview().offset(-5)
            make.height.equalTo(0.3)
            make.bottom.equalToSuperview().offset(-0.5)
        }
    }
}
