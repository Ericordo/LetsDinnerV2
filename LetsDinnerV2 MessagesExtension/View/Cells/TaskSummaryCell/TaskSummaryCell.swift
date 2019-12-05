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
    func taskSummaryDidTapSeeAllBeforeCreateEvent()
}

class TaskSummaryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var seeAllBeforeCreateEvent: UIButton!
    @IBOutlet weak var tasksCollectionView: UICollectionView!
    @IBOutlet weak var progressCircle: ProgressCircle!
    
    weak var delegate: TaskSummaryCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tasksCollectionView.delegate = self
        tasksCollectionView.dataSource = self
        tasksCollectionView.register(UINib(nibName: CellNibs.taskCVCell, bundle: nil), forCellWithReuseIdentifier: CellNibs.taskCVCell)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: NSNotification.Name("updateTable"), object: nil)
        
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
        delegate?.taskSummaryDidTapSeeAllBeforeCreateEvent()
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
         return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 55)
     }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 0.0
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 330, height: 80)
    }

}
