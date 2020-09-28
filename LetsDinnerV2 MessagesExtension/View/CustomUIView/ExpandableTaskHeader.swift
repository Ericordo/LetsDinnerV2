//
//  ExpandableTaskHeaderView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 14/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class ExpandableTaskHeaderView: UIView {
    
    var expandableTasks: [ExpandableTasks]?
    var section: Int?
    var sectionNames: [String]?
    
    var numberOfCompletedTasks = 0
    var numberOfUnassignedTasks = 0

    init(expandableTasks: [ExpandableTasks], section: Int,
         sectionNames: [String]) {
        self.expandableTasks = expandableTasks
        self.section = section
        self.sectionNames = sectionNames
        super.init(frame: CGRect.zero)
        configureView(expandableTasks: expandableTasks,
                      section: section,
                      sectionNames: sectionNames)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView(expandableTasks: [ExpandableTasks],
                               section: Int,
                               sectionNames: [String]) {
        self.backgroundColor = .backgroundColor
        // Update View
        expandableTasks[section].tasks.forEach { task in
            if task.taskState == .completed {
                numberOfCompletedTasks += 1
            }
        }
        expandableTasks[section].tasks.forEach { task in
            if task.taskState == .unassigned {
                numberOfUnassignedTasks += 1
            }
        }
        let percentage: Double = Double(numberOfCompletedTasks)/Double(expandableTasks[section].tasks.count)
        progressCircle.animate(percentage: percentage)
        #warning("Localize")
        if numberOfUnassignedTasks == 0 {
            progressLabel.text = "All items assigned"
        } else if numberOfUnassignedTasks == 1 {
            progressLabel.text = "\(numberOfUnassignedTasks) item unassigned"
        } else {
            progressLabel.text = "\(numberOfUnassignedTasks) items unassigned"
        }
        
        nameLabel.text = sectionNames[section]
        
        // Check if expandable
        if !expandableTasks[section].isExpanded {
              collapseImage.transform = CGAffineTransform(rotationAngle: -CGFloat((Double.pi/2)))
              }
    }
    
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
        image.image = Images.chevronDisclosureCollapsed
        image.contentMode = .scaleAspectFit
//        if !expandableTasks[section].isExpanded {
//        image.transform = CGAffineTransform(rotationAngle: -CGFloat((Double.pi/2)))
//        }
        image.restorationIdentifier = "collapse"
        return image
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    let separator : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cellSeparatorLine
        return view
    }()
    
    let progressLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryTextLabel
        return label
    }()
    
    let progressCircle = ProgressCircle(frame: CGRect(origin: .zero, size: CGSize(width: 25, height: 25)))
    
    override func layoutSubviews() {
        addConstraints()
    }
    
    private func addConstraints() {
//        headerView.addSubview(collapseButton)
        self.addSubview(collapseImage)
        self.addSubview(progressCircle)
        self.addSubview(nameLabel)
        self.addSubview(progressLabel)
        self.addSubview(separator)
        
//        collapseButton.translatesAutoresizingMaskIntoConstraints = false
//        collapseButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
//        collapseButton.heightAnchor.constraint(equalToConstant: 29).isActive = true
//        collapseButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
//        collapseButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0).isActive = true

        collapseImage.translatesAutoresizingMaskIntoConstraints = false
        collapseImage.widthAnchor.constraint(equalToConstant: 15).isActive = true
        collapseImage.heightAnchor.constraint(equalToConstant: 15).isActive = true
        collapseImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        collapseImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        progressCircle.translatesAutoresizingMaskIntoConstraints = false
        progressCircle.widthAnchor.constraint(equalToConstant: 25).isActive = true
        progressCircle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        progressCircle.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        progressCircle.trailingAnchor.constraint(equalTo: collapseImage.leadingAnchor, constant: -5).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: progressCircle.leadingAnchor, constant: 0).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        progressLabel.trailingAnchor.constraint(equalTo: progressCircle.leadingAnchor, constant: 0).isActive = true
        progressLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        progressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0).isActive = true
//        progressLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.75).isActive = true
        separator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        separator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
    }
}
