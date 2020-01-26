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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var seeAllBeforeCreateEvent: UIButton!
    @IBOutlet weak var tasksCollectionView: UICollectionView!
    @IBOutlet weak var progressCircle: ProgressCircle!
    
    weak var delegate: TaskSummaryCellDelegate?
    weak var reviewVCDelegate: TaskSummaryCellInReviewVCDelegate?
    
    let sortedTasks = Event.shared.tasks.sorted { $0.taskName < $1.taskName }

    override func awakeFromNib() {
        super.awakeFromNib()
        tasksCollectionView.delegate = self
        tasksCollectionView.dataSource = self
        tasksCollectionView.register(UINib(nibName: CellNibs.taskCVCell, bundle: nil), forCellWithReuseIdentifier: CellNibs.taskCVCell)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: NSNotification.Name("updateTable"), object: nil)
        
        if Event.shared.tasks.count != 0 {
            seeAllButton.setTitle("See All that's needed for \(Event.shared.servings)!", for: .normal)
            seeAllBeforeCreateEvent.setTitle("See All that's needed for \(Event.shared.servings)!", for: .normal)
        } else {
            seeAllButton.setTitle("Add some tasks here!", for: .normal)
            seeAllBeforeCreateEvent.setTitle("Add some tasks Here!", for: .normal)
        }
        
        
    }
    
    @objc func updateTable() {
           tasksCollectionView.reloadData()
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func didTapSeeAllButton(_ sender: UIButton) {
        delegate?.taskSummaryCellDidTapSeeAll()
    }
    
    @IBAction func didTapSeeAllBeforeCreateEvent(_ sender: UIButton) {
        reviewVCDelegate?.taskSummaryDidTapSeeAllBeforeCreateEvent()
    }
}

extension TaskSummaryCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sortedTasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let taskCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellNibs.taskCVCell, for: indexPath) as! TaskCVCell
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
        } else if targetOffset < currentOffset {
            newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
        }
        
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if (newTargetOffset > Float(scrollView.contentSize.width)){
            newTargetOffset = Float(Float(scrollView.contentSize.width))
        }

        targetContentOffset.pointee.x = CGFloat(currentOffset)
        scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: scrollView.contentOffset.y), animated: true)
    }
    
}
