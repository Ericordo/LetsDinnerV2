//
//  ReviewViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 17/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol ReviewViewControllerDelegate: class {
    func reviewVCDidTapPrevious(controller: ReviewViewController)
    func reviewVCDidTapSend(controller: ReviewViewController)
}

class ReviewViewController: UIViewController {
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var summaryTableView: UITableView!
    
    weak var delegate: ReviewViewControllerDelegate?
    
    let mailImageView : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "mail")
        image.contentMode = .scaleAspectFit
        image.alpha = 0
        return image
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        StepStatus.currentStep = .reviewVC
        summaryTableView.delegate = self
        summaryTableView.dataSource = self
        registerCell(CellNibs.answerCell)
        registerCell(CellNibs.infoCell)
        registerCell(CellNibs.descriptionCell)
        registerCell(CellNibs.taskSummaryCell)
        setupUI()
        
        
    }
    
    private func setupUI() {
        progressView.progressTintColor = Colors.newGradientRed
        progressView.trackTintColor = .white
        progressView.progress = 4/5
        progressView.setProgress(1, animated: true)
        sendButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 8.0
        sendButton.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        summaryTableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func registerCell(_ nibName: String) {
           summaryTableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
       }
    
    
    @IBAction func didTapPrevious(_ sender: UIButton) {
        delegate?.reviewVCDidTapPrevious(controller: self)
    }

    @IBAction func didTapSend(_ sender: Any) {
//        delegate?.reviewVCDidTapSend(controller: self)
        animateSending()
    }
    
    private func animateSending() {
        view.addSubview(mailImageView)
        mailImageView.translatesAutoresizingMaskIntoConstraints = false
        mailImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        mailImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        mailImageView.widthAnchor.constraint(equalToConstant: 105).isActive = true
        mailImageView.heightAnchor.constraint(equalToConstant: 105).isActive = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.summaryTableView.alpha = 0
            self.mailImageView.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.mailImageView.transform = CGAffineTransform(translationX: 0, y: -200)
                self.mailImageView.alpha = 0
            }) { (_) in
                self.delegate?.reviewVCDidTapSend(controller: self)
            }
        }
    }
    
  

}

extension ReviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let answerCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.answerCell) as! AnswerCell
              let infoCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.infoCell) as! InfoCell
              let descriptionCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.descriptionCell) as! DescriptionCell
              let taskSummaryCell = tableView.dequeueReusableCell(withIdentifier: CellNibs.taskSummaryCell) as! TaskSummaryCell
        
        switch indexPath.row {
        case 0:
           
                if answerCell.acceptButton != nil && answerCell.declineButton != nil {
                    answerCell.acceptButton.removeFromSuperview()
                    answerCell.declineButton.removeFromSuperview()
                    answerCell.questionLabel.removeFromSuperview()
                }
//            answerCell.titleLabel.text = Event.shared.dinnerName
        
            return answerCell

        case 1:
            infoCell.titleLabel.text = LabelStrings.host
            infoCell.infoLabel.text = Event.shared.hostName
            return infoCell
        case 2:
            infoCell.titleLabel.text = LabelStrings.date
            infoCell.infoLabel.text = Event.shared.dinnerDate
            return infoCell
        case 3:
            infoCell.titleLabel.text = LabelStrings.location
            infoCell.infoLabel.text = Event.shared.dinnerLocation
            return infoCell
        case 4:
            descriptionCell.descriptionLabel.text = Event.shared.recipeTitles + "\n" + Event.shared.eventDescription
            return descriptionCell
        case 5:
            taskSummaryCell.seeAllButton.isHidden = true
            var numberOfCompletedTasks = 0
            Event.shared.tasks.forEach { task in
                if task.taskState == .completed {
                    numberOfCompletedTasks += 1
                }
            }
            let percentage = CGFloat(numberOfCompletedTasks)/CGFloat(Event.shared.tasks.count)
            taskSummaryCell.progressCircle.animate(percentage: percentage)
            return taskSummaryCell
        default:
            break
        }
        return UITableViewCell()
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1, 2, 3:
            return 52
        case 5:
            return 240
        default:
            return UITableView.automaticDimension
        }
    }
    
    
}
