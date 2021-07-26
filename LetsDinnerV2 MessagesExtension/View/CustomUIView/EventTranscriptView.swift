//
//  EventTranscriptView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 29/03/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import Messages
import FirebaseDatabase

protocol EventTranscriptViewDelegate: AnyObject {
    func didTapBubble()
}

class EventTranscriptView: UIView {
    
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 110))
        imageView.image = Images.premiumBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let mainInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let secondaryInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.bubbleBottom
        return view
    }()
    
    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 13.5
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.textLabel
        label.font = UIFont.systemFont(ofSize: 11)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.secondaryTextLabel
        return label
    }()
    
    private let chevronImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.chevronDisclosure
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    weak var delegate: EventTranscriptViewDelegate?
    
    private let messageIsFromMe : Bool
    
    init(bubbleInfo: BubbleInfo,
         delegate: EventTranscriptViewDelegate,
         messageIsFromMe: Bool) {
        self.delegate = delegate
        self.messageIsFromMe = messageIsFromMe
        super.init(frame: .zero)
        setupInformation(bubbleInfo: bubbleInfo)
        setupView()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupInformation(bubbleInfo: BubbleInfo) {
        dateLabel.text = self.setupDate(bubbleInfo.eventDateTimestamp)
        titleLabel.text = bubbleInfo.eventName
        mainInfoLabel.text = bubbleInfo.mainInformation
        secondaryInfoLabel.text = bubbleInfo.secondaryInformation
        updateUserStatus(bubbleInfo.userStatus)
    }
    
    @objc private func didTapBubble() {
        delegate?.didTapBubble()
    }
    
    private func setupDate(_ timestamp: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy h:mm a"
        let date = Date(timeIntervalSince1970: timestamp)
        let dateString = timestamp == 0 ? "" : dateFormatter.string(from: date)
        return dateString
    }
    
    private func updateUserStatus(_ value: String) {
        if let status = Invitation(rawValue: value) {
            switch status {
            case .accepted:
                statusIcon.image = Images.statusAccepted
            case .declined:
                statusIcon.image = Images.statusDeclined
            case .pending:
                statusIcon.image = Images.statusPending
            }
        } else {
            statusIcon.image = Images.statusPending
        }
    }
    
    private func setupView() {
        preservesSuperviewLayoutMargins = true 
        addSubview(backgroundImage)
        addSubview(bottomView)
        addSubview(secondaryInfoLabel)
        addSubview(mainInfoLabel)
        bottomView.addSubview(statusIcon)
        bottomView.addSubview(dateLabel)
        bottomView.addSubview(titleLabel)
        bottomView.addSubview(chevronImage)
        addConstraints()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBubble))
        bottomView.addGestureRecognizer(tapGesture)
    }
    
    private func addConstraints() {
        let leadingConstant: CGFloat = messageIsFromMe ? 0 : 3
        let trailingConstant: CGFloat = messageIsFromMe ? -3 : 0
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 41)
        ])
        
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImage.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: self.topAnchor)
        ])
        
        secondaryInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondaryInfoLabel.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -7),
            secondaryInfoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7 + leadingConstant),
            secondaryInfoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -7 + trailingConstant),
            secondaryInfoLabel.heightAnchor.constraint(equalToConstant: secondaryInfoLabel.font.lineHeight)
        ])
        
        mainInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainInfoLabel.bottomAnchor.constraint(equalTo: secondaryInfoLabel.topAnchor, constant: -2),
            mainInfoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7 + leadingConstant),
            mainInfoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -7 + trailingConstant),
            mainInfoLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusIcon.widthAnchor.constraint(equalToConstant: 27),
            statusIcon.heightAnchor.constraint(equalToConstant: 27),
            statusIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7 + leadingConstant),
            statusIcon.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 7),
            dateLabel.bottomAnchor.constraint(equalTo: statusIcon.bottomAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -7),
            dateLabel.heightAnchor.constraint(equalToConstant: dateLabel.font.lineHeight)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 7),
            titleLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -1),
//            titleLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -7),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: bottomView.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight)
        ])
        
        chevronImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chevronImage.widthAnchor.constraint(equalToConstant: 9),
            chevronImage.heightAnchor.constraint(equalToConstant: 11),
            chevronImage.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
            chevronImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
//            chevronImage.topAnchor.constraint(equalTo: statusIcon.topAnchor)
        ])
    }
}

