//
//  TaskSummaryCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol TaskSummaryCellDelegate: class {
    func taskSummaryCellDidTapSeeAll()
}

protocol TaskSummaryCellInReviewVCDelegate: class {
    func taskSummaryDidTapSeeAllBeforeCreateEvent()
}

class TaskSummaryCell: UITableViewCell {
    
    static let reuseID = "TaskSummaryCell"
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = LabelStrings.somethingMissing
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .textLabel
        return label
    }()
    
    private lazy var seeAllButton : UIButton = {
        let button = UIButton()
        button.setTitleColor(.activeButton, for: .normal)
        button.addTarget(self, action: #selector(didTapSeeAll), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    let progressCircle = ProgressCircle(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 36.5)))
    
    private let taskSummaryLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.numberOfLines = 0
        return label
    }()

    private let tasksCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .backgroundColor
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let separatorLine : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    private let chevronImage : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Images.chevronRight
        return imageView
    }()
    
    weak var delegate: TaskSummaryCellDelegate?
    
    weak var reviewVCDelegate: TaskSummaryCellInReviewVCDelegate?
    
    private var sortedTasks : [Task] {
        return Event.shared.tasks.sorted { $0.name < $1.name }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupCollectionView()
        updateTaskSummaryLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        self.clipsToBounds = true
        var buttonTitle = ""
        if StepStatus.currentStep == .reviewVC {
            buttonTitle = Event.shared.tasks.isEmpty ? LabelStrings.addSomeTasks : String.localizedStringWithFormat(LabelStrings.whatsNeeded, Event.shared.servings)
        } else if StepStatus.currentStep == .eventSummaryVC {
            buttonTitle = Event.shared.tasks.isEmpty ? LabelStrings.nothingToDo : String.localizedStringWithFormat(LabelStrings.whatsNeeded, Event.shared.servings)
        }
        self.seeAllButton.setTitle(buttonTitle, for: .normal)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTable),
                                               name: NSNotification.Name("updateTable"), object: nil)
        self.contentView.addSubview(progressCircle)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(seeAllButton)
        self.contentView.addSubview(chevronImage)
        self.contentView.addSubview(separatorLine)
        self.contentView.addSubview(tasksCollectionView)
        self.contentView.addSubview(taskSummaryLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        progressCircle.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(36.5)
            make.leading.equalToSuperview().offset(27)
            make.top.equalToSuperview().offset(10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(progressCircle.snp.trailing).offset(10)
            make.centerY.equalTo(progressCircle)
            make.height.equalTo(27)
        }
        
        seeAllButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(29)
        }
        
        chevronImage.snp.makeConstraints { make in
            make.height.width.equalTo(15)
            make.leading.equalTo(seeAllButton.snp.trailing).offset(5)
            make.centerY.equalTo(seeAllButton)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.height.equalTo(0.3)
            make.leading.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalTo(seeAllButton.snp.bottom).offset(10)
        }
        
        tasksCollectionView.snp.makeConstraints { make in
            make.top.equalTo(seeAllButton.snp.bottom).offset(15)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(260)
        }
        
        taskSummaryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(33)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    private func setupCollectionView() {
        tasksCollectionView.delegate = self
        tasksCollectionView.dataSource = self
        tasksCollectionView.register(TaskCVCell.self,
                                     forCellWithReuseIdentifier: TaskCVCell.reuseID)
    }
    
    private func updateTaskSummaryLabel() {
        if Event.shared.tasks.isEmpty {
            taskSummaryLabel.isHidden = false
            tasksCollectionView.removeFromSuperview()
            taskSummaryLabel.text = LabelStrings.nothingToDoLabel
        } else {
            if Event.shared.allTasksCompleted {
                taskSummaryLabel.isHidden = false
                tasksCollectionView.removeFromSuperview()
                taskSummaryLabel.text = LabelStrings.allDoneLabel
            } else {
                taskSummaryLabel.isHidden = true
            }
        }
    }
    
    @objc private func updateTable() {
        tasksCollectionView.reloadData()
    }
    
    @objc private func didTapSeeAll() {
        if StepStatus.currentStep == .eventSummaryVC {
             delegate?.taskSummaryCellDidTapSeeAll()
        } else if StepStatus.currentStep == .reviewVC {
            reviewVCDelegate?.taskSummaryDidTapSeeAllBeforeCreateEvent()
        }
    }
}

extension TaskSummaryCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sortedTasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let taskCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCVCell.reuseID, for: indexPath) as! TaskCVCell
        let task = self.sortedTasks[indexPath.row]
        let count = Int(indexPath.row) + 1
        taskCVCell.configureCell(task: task, count: count)
        return taskCVCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !Event.shared.firebaseEventUid.isEmpty {
            delegate?.taskSummaryCellDidTapSeeAll()
        }
    }
}

extension TaskSummaryCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // For the pagination
         return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 60)
     }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 0
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 330, height: 80)
    }

    // Pagination
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth: Float = 330
        // width + space
        let currentOffset: Float = Float(scrollView.contentOffset.x)
        let targetOffset: Float = Float(targetContentOffset.pointee.x)
        var newTargetOffset: Float = 0
        
        // Drag
        if targetOffset > currentOffset {
            newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
        } else { //if targetOffset < currentOffset
            newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
        }
        // and targetoffset is not over certain page
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if (newTargetOffset > Float(scrollView.contentSize.width)){
            newTargetOffset = Float(scrollView.contentSize.width)
        }
        targetContentOffset.pointee.x = CGFloat(currentOffset)
        scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: scrollView.contentOffset.y), animated: true)
    }
}
