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
    
    private var indexOfCellBeforeDragging = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tasksCollectionView.delegate = self
        tasksCollectionView.dataSource = self
        tasksCollectionView.register(UINib(nibName: CellNibs.taskCVCell, bundle: nil), forCellWithReuseIdentifier: CellNibs.taskCVCell)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: NSNotification.Name("updateTable"), object: nil)
        seeAllButton.setTitle("See what is needed for \(Event.shared.servings)!", for: .normal)
        seeAllBeforeCreateEvent.setTitle("See what is needed for \(Event.shared.servings)!", for: .normal)
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
        return Event.shared.tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let taskCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellNibs.taskCVCell, for: indexPath) as! TaskCVCell
        let task = Event.shared.tasks[indexPath.row]
        let count = Int(indexPath.row) + 1
        taskCVCell.configureCell(task: task, count: count)
        return taskCVCell
    }
}

extension TaskSummaryCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
     }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 0
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 330, height: 80)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pageWidth: CGFloat = 200 // The width your page should have (plus a possible margin)
        let proportionalOffset = tasksCollectionView.contentOffset.x / pageWidth
        indexOfCellBeforeDragging = Int(round(proportionalOffset))
    }


    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrolling
        targetContentOffset.pointee = scrollView.contentOffset

        // Calculate conditions
        let pageWidth: CGFloat = 200 // The width your page should have (plus a possible margin)
        let collectionViewItemCount = Event.shared.tasks.count // The number of items in this section
        let proportionalOffset = tasksCollectionView.contentOffset.x / pageWidth
        let indexOfMajorCell = Int(round(proportionalOffset))
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < collectionViewItemCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {
            // Animate so that swipe is just continued
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = pageWidth * CGFloat(snapToIndex)
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: velocity.x,
                options: .allowUserInteraction,
                animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            // Pop back (against velocity)
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            tasksCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
}
