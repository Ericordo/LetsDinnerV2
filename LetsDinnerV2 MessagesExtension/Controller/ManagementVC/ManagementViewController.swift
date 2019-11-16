//
//  ManagementViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 15/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol ManagementViewControllerDelegate: class {
    func managementVCDidTapBack(controller: ManagementViewController)
    func managementVCDdidTapNext(controller: ManagementViewController)
}

class ManagementViewController: UIViewController {
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var tasksTableView: UITableView!
    @IBOutlet private weak var addButton: UIButton!
    
    weak var delegate: ManagementViewControllerDelegate?
    
    private var tasks = Event.shared.tasks
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(UINib(nibName: CellNibs.taskCell, bundle: nil), forCellReuseIdentifier: CellNibs.taskCell)
        setupUI()
//        prepareTasks()
//        tasksTableView.tableFooterView = UIView()
        
    }
    
    private func setupUI() {
        progressView.progressTintColor = Colors.newGradientRed
        progressView.trackTintColor = .white
        progressView.progress = 2/4
        progressView.setProgress(3/4, animated: true)
        
        
    }
 
    
    
    @IBAction private func didTapBack(_ sender: UIButton) {
        delegate?.managementVCDidTapBack(controller: self)
    }
    
    @IBAction private func didTapNext(_ sender: UIButton) {
        delegate?.managementVCDdidTapNext(controller: self)
    }
    
    @IBAction private func didTapAdd(_ sender: UIButton) {
        
    }
    
    


 

}

extension ManagementViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tasks.count == 0 {
            tableView.setEmptyView(title: LabelStrings.noTaskTitle, message: LabelStrings.noTaskMessage)
        } else {
        tableView.restore()
        }

        return tasks.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let taskCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskCell, for: indexPath) as! TaskCell
          let task = tasks[indexPath.row]
          taskCell.configureCell(task: task, indexPath: indexPath.row)
          taskCell.delegate = self
          return taskCell
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
        cell.didTapTaskStatusButton()
    }
      
      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return UITableView.automaticDimension
       }
    
    
    
    
}

extension ManagementViewController: TaskCellDelegate {
    func taskCellDidTapTaskStatusButton() {
        
    }
    
    
}
