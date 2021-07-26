//
//  TaskManagementCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol TaskManagementCellDelegate: AnyObject {
    func taskManagementCellDidTapTaskStatusButton(indexPath: IndexPath)
}

class TaskManagementCell: UITableViewCell {
        
    static let reuseID = "TaskManagementCell"
    
    private let taskStatusButton = TaskStatusButton()
    
    private let taskNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textLabel
        return label
    }()
    
    private let personLabel = TaskPersonLabel()
    
    private let separatorLine : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    var task: Task?
    
    weak var delegate: TaskManagementCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(task: Task) {
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
               } else {
                   if task.state == .completed {
                       personLabel.text = AlertStrings.completed
                   } else {
                       personLabel.text = AlertStrings.assignedToMyself
                   }
                   personLabel.setTextAttributes(userOwnsTask: true)
               }
           } else {
            personLabel.setTextAttributes(userOwnsTask: false)
            personLabel.text = AlertStrings.noAssignment
        }
        
        taskStatusButton.isUserInteractionEnabled = false
        
        self.backgroundColor = .backgroundColor
        separatorLine.backgroundColor = UIColor.cellSeparatorLine
    }
    
    func didTapTaskStatusButton(indexPath: IndexPath) {
        guard let task = task else { return }
        switch task.state {
        case .unassigned:
            personLabel.setTextAttributes(userOwnsTask: true)
            task.ownerName = defaults.username
            task.ownerId = Event.shared.currentUser?.identifier
            task.state = .assigned
            personLabel.text = AlertStrings.assignedToMyself
        case .assigned:
            task.state = .completed
            task.ownerName = defaults.username
            task.ownerId = Event.shared.currentUser?.identifier
            personLabel.text = AlertStrings.completed
        case .completed:
            personLabel.setTextAttributes(userOwnsTask: false)
            task.state = .unassigned
            task.ownerName = "nil"
            task.ownerId = "nil"
            personLabel.text = AlertStrings.noAssignment
        }
        delegate?.taskManagementCellDidTapTaskStatusButton(indexPath: indexPath)
        
        taskStatusButton.setState(state: task.state)
        if let index = Event.shared.tasks.firstIndex(where: { $0.id == task.id }) {
            Event.shared.tasks[index] = task
        }
    }
    
    func didSwipeTaskStatusButton(indexPath: IndexPath, changeTo: TaskState) {
        guard let task = task else { return }
        switch changeTo {
        case .assigned:
            personLabel.setTextAttributes(userOwnsTask: true)
            task.ownerName = defaults.username
            task.ownerId = Event.shared.currentUser?.identifier
            task.state = .assigned
            personLabel.text = AlertStrings.assignedToMyself
        case .completed:
            task.state = .completed
            task.ownerName = defaults.username
            task.ownerId = Event.shared.currentUser?.identifier
            personLabel.text = AlertStrings.completed
            delegate?.taskManagementCellDidTapTaskStatusButton(indexPath: indexPath)
        default:
            break
        }
        
        taskStatusButton.setState(state: task.state)
        if let index = Event.shared.tasks.firstIndex(where: { $0.id == task.id }) {
            Event.shared.tasks[index] = task
        }
    }
    
    private func setupCell() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        contentView.addSubview(taskStatusButton)
        contentView.addSubview(taskNameLabel)
        contentView.addSubview(personLabel)
        contentView.addSubview(separatorLine)
        addConstraints()
    }
    
    private func addConstraints() {
        taskStatusButton.snp.makeConstraints { make in
            make.height.width.equalTo(22)
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        
        taskNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(taskStatusButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalTo(taskStatusButton)
        }
        
        personLabel.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.bottom.equalToSuperview().offset(-11)
            make.leading.trailing.equalTo(taskNameLabel)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.leading.equalTo(taskNameLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(0.3)
            make.bottom.equalToSuperview().offset(-0.5)
        }
    }
    
}
