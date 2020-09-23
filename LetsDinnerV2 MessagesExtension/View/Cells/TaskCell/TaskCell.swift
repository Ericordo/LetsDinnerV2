//
//  TaskCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol TaskCellDelegate: class {
    func taskCellDidTapTaskStatusButton()
    func taskCellUpdateProgress(indexPath: IndexPath)
}

class TaskCell: UITableViewCell {
    
    static let reuseID = "TaskCell"
    
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
    var indexPath = 0
    weak var delegate: TaskCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTapTaskStatusButton(indexPath: IndexPath) {
        guard let task = task else { return }
        switch task.taskState {
        case .unassigned:
            personLabel.setTextAttributes(taskIsOwnedByUser: true)
            task.assignedPersonName = defaults.username
            task.assignedPersonUid = Event.shared.currentUser?.identifier
            task.taskState = .assigned
            personLabel.text = AlertStrings.assignedToMyself
            delegate?.taskCellUpdateProgress(indexPath: indexPath)
            taskStatusButton.setState(state: task.taskState)
        case .assigned:
            if Event.shared.currentUser?.identifier == task.assignedPersonUid {
                task.taskState = .completed
                task.assignedPersonName = defaults.username
                task.assignedPersonUid = Event.shared.currentUser?.identifier
                personLabel.text = AlertStrings.completed
                taskStatusButton.setState(state: task.taskState)
                delegate?.taskCellUpdateProgress(indexPath: indexPath)
            }
        case .completed:
            if Event.shared.currentUser?.identifier == task.assignedPersonUid {
                task.taskState = .unassigned
                task.assignedPersonName = "nil"
                task.assignedPersonUid = "nil"
                personLabel.text = ""
                taskStatusButton.setState(state: task.taskState)
                delegate?.taskCellUpdateProgress(indexPath: indexPath)
            }
        }
        if let index = Event.shared.tasks.firstIndex(where: { $0.taskUid == task.taskUid }) {
            Event.shared.tasks[index] = task
        }
        delegate?.taskCellDidTapTaskStatusButton()
    }
    
    func configureCell(task: Task, indexPath: Int) {
        self.task = task
        self.indexPath = indexPath
                if let amount = task.metricAmount {
            if amount.truncatingRemainder(dividingBy: 1) == 0.0 {
                if let unit = task.metricUnit {
                    taskNameLabel.text = "\(task.taskName), \(String(format:"%.0f", amount)) \(unit)"
                } else {
                    taskNameLabel.text = "\(task.taskName), \(String(format:"%.0f", amount))"
                }
            } else {
                if let unit = task.metricUnit {
                    taskNameLabel.text = "\(task.taskName), \(String(format:"%.1f", amount)) \(unit)"
                } else {
                    taskNameLabel.text = "\(task.taskName), \(String(format:"%.1f", amount))"
                }
            }
        } else {
            taskNameLabel.text = task.taskName
        }
        taskStatusButton.setState(state: task.taskState)
        if task.taskState == .assigned || task.taskState == .completed {
            if Event.shared.currentUser?.identifier != task.assignedPersonUid {
                personLabel.text = task.assignedPersonName
                personLabel.setTextAttributes(taskIsOwnedByUser: false)
                taskStatusButton.setColorAttributes(ownedByUser: false, taskState: task.taskState)
            } else {
                if task.taskState == .completed {
                    personLabel.text = AlertStrings.completed
                } else {
                    personLabel.text = AlertStrings.assignedToMyself
                }
                personLabel.setTextAttributes(taskIsOwnedByUser: true)
                taskStatusButton.setColorAttributes(ownedByUser: true, taskState: task.taskState)
            }
        } else {
            personLabel.setTextAttributes(taskIsOwnedByUser: false)
            personLabel.text = AlertStrings.noAssignment
        }
        taskStatusButton.isUserInteractionEnabled = false
        separatorLine.backgroundColor = UIColor.cellSeparatorLine
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
