//
//  TasksListViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 07/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol TasksListViewControllerDelegate: class {
    func tasksListVCDidTapBackButton(controller: TasksListViewController)
    func tasksListVCDidTapSubmit(controller: TasksListViewController)
}

class TasksListViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var onlineAlertHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: TasksListViewControllerDelegate?
    
    private var tasks = Event.shared.tasks.sorted { $0.taskName < $1.taskName }
//    private var sortedTasks = Event.shared.tasks.sorted { $0.taskName < $1.taskName }
    private var classifiedTasks = [[Task]]()
    private var expandableTasks = [ExpandableTasks]()
    private var sectionNames = [String]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .tasksListVC
        
        setupUI()
        setupTableView()
        prepareData()
        tasksTableView.reloadData()
        
        Database.database().reference().child("Events").child(Event.shared.firebaseEventUid).child("onlineUsers").observe(.value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            self.updateOnlineAlert(value)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        Event.shared.addOnlineUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Event.shared.removeOnlineUser()
    }
    
    func setupUI() {
//        backButton.setTitle(" \(Event.shared.dinnerName)", for: .normal)
        submitButton.layer.masksToBounds = true
        submitButton.alpha = 0.5
        submitButton.layer.cornerRadius = 12
        submitButton.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
    }
    
    func setupTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(UINib(nibName: CellNibs.taskCell, bundle: nil), forCellReuseIdentifier: CellNibs.taskCell)
    }
    
    func updateOnlineAlert(_ value: Int) {
        if value < 2 {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2) {
                self.onlineAlertHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        } else if value > 1 {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2) {
                self.onlineAlertHeightConstraint.constant = 40
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func prepareData() {
//        tasks = Event.shared.tasks
        classifiedTasks.removeAll()
        expandableTasks.removeAll()
        sectionNames.removeAll()
        tasks.forEach { task in
            if classifiedTasks.contains(where: { subTasks -> Bool in
                subTasks.contains { (individualTask) -> Bool in
                    individualTask.parentRecipe == task.parentRecipe
                }
            }) {
                let index = classifiedTasks.firstIndex { (subTasks) -> Bool in
                    subTasks.contains { (individualTask) -> Bool in
                        individualTask.parentRecipe == task.parentRecipe
                    }
                }
                classifiedTasks[index!].append(task)
            } else {
                classifiedTasks.append([task])
            }
        }
        classifiedTasks.forEach { subtasks in
            let subExpandableTasks = ExpandableTasks(isExpanded: true, tasks: subtasks)
            expandableTasks.append(subExpandableTasks)
            if let sectionName = subtasks.first?.parentRecipe {
                sectionNames.append(sectionName)
            }
        }
    }


    @IBAction func didTapBack(_ sender: UIButton) {
        let difference = Event.shared.tasks.difference(from: Event.shared.currentConversationTaskStates)
        if !difference.isEmpty {
            let alert = UIAlertController(title: MessagesToDisplay.unsubmittedTasks, message: MessagesToDisplay.submitQuestion, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: MessagesToDisplay.yes, style: .default, handler: { action in
                self.didTapSubmit(self.submitButton)
            }))
            alert.addAction(UIAlertAction(title: MessagesToDisplay.no, style: .destructive, handler: { action in
                var newTasks = [Task]()
                Event.shared.currentConversationTaskStates.forEach { task in
                    let newTask = Task(taskName: task.taskName, assignedPersonUid: task.assignedPersonUid, taskState: task.taskState.rawValue, taskUid: task.taskUid, assignedPersonName: task.assignedPersonName, isCustom: task.isCustom, parentRecipe: task.parentRecipe)
                    if let amount = task.metricAmount, let unit = task.metricUnit {
                        newTask.metricAmount = amount
                        newTask.metricUnit = unit
                    }
                    newTasks.append(newTask)
                }
                Event.shared.tasks = newTasks
                self.prepareData()
                self.delegate?.tasksListVCDidTapBackButton(controller: self)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            self.delegate?.tasksListVCDidTapBackButton(controller: self)
        }
    }
    
    @IBAction func didTapSubmit(_ sender: UIButton) {
        Event.shared.isTaskUpdated = true
        delegate?.tasksListVCDidTapSubmit(controller: self)
    }
    
    
    @IBAction func didTapSortButton(_ sender: UIButton) {
        tasks = tasks.sorted(by: { $0.taskState.rawValue < $1.taskState.rawValue } )
        prepareData()
        tasksTableView.reloadData()
    }
    
}

extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if Event.shared.tasks.count == 0 {
            tableView.setEmptyView(title: LabelStrings.nothingToDo, message: "")
        } else {
            tableView.restore()
        }
        
        if !expandableTasks[section].isExpanded {
            return 0
        }
        return expandableTasks[section].tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskCell, for: indexPath) as! TaskCell
        let task = expandableTasks[indexPath.section].tasks[indexPath.row]
        taskCell.configureCell(task: task, indexPath: indexPath.row)
        taskCell.delegate = self
        return taskCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 80
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let taskCell = tableView.cellForRow(at: indexPath) as! TaskCell
        taskCell.didTapTaskStatusButton(indexPath: indexPath)
     }
    
    func numberOfSections(in tableView: UITableView) -> Int {
          if Event.shared.tasks.count == 0 {
                    tableView.setEmptyView(title: LabelStrings.nothingToDo, message: "")
                } else {
                tableView.restore()
                }
          
          return expandableTasks.count
      }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .white
        headerView.tag = section
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCloseCollapse)))
        
//        let collapseButton : UIButton = {
//            let button = UIButton()
//            button.setImage(UIImage(named: "collapse"), for: .normal)
//            if !expandableTasks[section].isExpanded {
//                button.transform = CGAffineTransform(rotationAngle: -CGFloat((Double.pi/2)))
//            }
//            button.tag = section
//            button.addTarget(self, action: #selector(handleCloseCollapse), for: .touchUpInside)
//            return button
//        }()
        
        let collapseImage : UIImageView = {
            let image = UIImageView()
            image.image = UIImage(named: "collapse")
            image.contentMode = .scaleAspectFit
            if !expandableTasks[section].isExpanded {
                image.transform = CGAffineTransform(rotationAngle: -CGFloat((Double.pi/2)))
            }
            image.restorationIdentifier = "collapse"
            return image
        }()
        
        let nameLabel : UILabel = {
            let label = UILabel()
            label.text = sectionNames[section]
            return label
        }()
        
        let separator : UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.lightGray
            return view
        }()
        
        let progressLabel : UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            label.textColor = .systemGray
            return label
        }()
        
        let progressCircle = ProgressCircle(frame: CGRect(origin: .zero, size: CGSize(width: 25, height: 25)))
        
        
//        headerView.addSubview(collapseButton)
        headerView.addSubview(collapseImage)
        headerView.addSubview(progressCircle)
        headerView.addSubview(nameLabel)
        headerView.addSubview(progressLabel)
        headerView.addSubview(separator)
        
        
//        collapseButton.translatesAutoresizingMaskIntoConstraints = false
//        collapseButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
//        collapseButton.heightAnchor.constraint(equalToConstant: 29).isActive = true
//        collapseButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
//        collapseButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0).isActive = true
        
        collapseImage.translatesAutoresizingMaskIntoConstraints = false
        collapseImage.widthAnchor.constraint(equalToConstant: 15).isActive = true
        collapseImage.heightAnchor.constraint(equalToConstant: 15).isActive = true
        collapseImage.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10).isActive = true
        collapseImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0).isActive = true
        
        progressCircle.translatesAutoresizingMaskIntoConstraints = false
        progressCircle.widthAnchor.constraint(equalToConstant: 25).isActive = true
        progressCircle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        progressCircle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
//        progressCircle.trailingAnchor.constraint(equalTo: collapseButton.leadingAnchor, constant: -5).isActive = true
        progressCircle.trailingAnchor.constraint(equalTo: collapseImage.leadingAnchor, constant: -5).isActive = true
        
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: progressCircle.leadingAnchor, constant: 0).isActive = true
        nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        nameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        progressLabel.trailingAnchor.constraint(equalTo: progressCircle.leadingAnchor, constant: 0).isActive = true
//        progressLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
        progressLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        progressLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5).isActive = true
        
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
        separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
        separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        
        //        number of completed task in section / number of task in section
        var numberOfCompletedTasks = 0
        expandableTasks[section].tasks.forEach { task in
            if task.taskState == .completed {
                numberOfCompletedTasks += 1
            }
        }
        let percentage : Double = Double(numberOfCompletedTasks)/Double(expandableTasks[section].tasks.count)
        progressCircle.animate(percentage: percentage)
        
        var numberOfUnassignedTasks = 0
        expandableTasks[section].tasks.forEach { task in
            if task.taskState == .unassigned {
                numberOfUnassignedTasks += 1
            }
        }
        
        if numberOfUnassignedTasks == 0 {
            progressLabel.text = "All items assigned"
        } else if numberOfUnassignedTasks == 1 {
            progressLabel.text = "\(numberOfUnassignedTasks) item unassigned"
        } else {
            progressLabel.text = "\(numberOfUnassignedTasks) items unassigned"
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
//    @objc func handleCloseCollapse(button: UIButton) {
//        button.rotate()
//        let section = button.tag
//        var indexPaths = [IndexPath]()
//        for row in expandableTasks[section].tasks.indices {
//            let indexPath = IndexPath(row: row, section: section)
//            indexPaths.append(indexPath)
//        }
//
//        let isExpanded = expandableTasks[section].isExpanded
//        expandableTasks[section].isExpanded = !isExpanded
//
//        if isExpanded {
//            tasksTableView.deleteRows(at: indexPaths, with: .fade)
//        } else {
//            tasksTableView.insertRows(at: indexPaths, with: .fade)
//        }
//    }
    
    @objc func handleCloseCollapse(sender: UITapGestureRecognizer) {
        let section = sender.view!.tag
        sender.view?.subviews.forEach({ subview in
            if subview.restorationIdentifier == "collapse" {
                subview.rotate()
            }
        })
        var indexPaths = [IndexPath]()
        for row in expandableTasks[section].tasks.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }

        let isExpanded = expandableTasks[section].isExpanded
        expandableTasks[section].isExpanded = !isExpanded

        if isExpanded {
            tasksTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tasksTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    
}

extension TasksListViewController: TaskCellDelegate {
    func taskCellUpdateProgress(indexPath: IndexPath) {
        let indexSet = NSMutableIndexSet()
        indexSet.add(indexPath.section)
        UIView.performWithoutAnimation {
            self.tasksTableView.reloadSections(indexSet as IndexSet, with: .none)
        }
    }
    
    func taskCellDidTapTaskStatusButton() {
        let difference = Event.shared.tasks.difference(from: Event.shared.currentConversationTaskStates)
        if !difference.isEmpty {
            submitButton.isEnabled = true
            submitButton.alpha = 1.0
        } else {
            submitButton.isEnabled = false
            submitButton.alpha = 0.5
        }
        Event.shared.summary = "\(defaults.username) updated \(Event.shared.getAssignedNewTasks() + Event.shared.getCompletedTasks()) tasks for \(Event.shared.dinnerName)."
    }
    
    
}
