//
//  BubbleManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 29/03/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import Messages
import iMessageDataKit

struct BubbleInfo {
    var eventName: String = ""
    var eventDate: String = ""
    var mainInformation: String = ""
    var secondaryInformation: String = ""
    var userStatus: String = ""
}

class BubbleManager {
    
    var localEventId: String?
    
    private enum Keys {
        static let eventName = "eventName"
        static let eventDate = "eventDate"
        static let mainInformation = "mainInformation"
        static let secondaryInformation = "secondaryInformation"
        static let status = "status"
        static let localEventId = "localEventId"
    }
    
    func prepareMessageBubble() -> MSMessageLiveLayout {
        let layout = MSMessageLiveLayout(alternateLayout: prepareAlternateLayout())
        return layout
    }
    
    func storeBubbleInformation(for message: MSMessage, for sendAction: SendAction) {
        message.md.set(value: Event.shared.dinnerName, forKey: Keys.eventName)
        var eventDate : String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy h:mm a"
            let date = Date(timeIntervalSince1970: Event.shared.dateTimestamp)
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
        message.md.set(value: eventDate, forKey: Keys.eventDate)
        message.md.set(value: Event.shared.summary, forKey: Keys.mainInformation)
        let numberOfRemainingTasks = Event.shared.getRemainingTasks()
        var participantsConfirmed : Int {
            var number = 0
            Event.shared.participants.forEach { user in
                if user.hasAccepted == .accepted {
                    number += 1
                }
            }
            return number
        }
        switch sendAction {
        case .answerInvitation:
            let secondaryInfo = String.localizedStringWithFormat(LabelStrings.participantsNumber, participantsConfirmed)
            message.md.set(value: secondaryInfo, forKey: Keys.secondaryInformation)
        case .createEvent:
            let secondaryInfo = LabelStrings.partyEmoji
            message.md.set(value: secondaryInfo, forKey: Keys.secondaryInformation)
        case.cancelEvent:
            let secondaryInfo = LabelStrings.sadEmoji
            message.md.set(value: secondaryInfo, forKey: Keys.secondaryInformation)
        case.rescheduleEvent:
            let secondaryInfo = LabelStrings.payAttention
            message.md.set(value: secondaryInfo, forKey: Keys.secondaryInformation)
        case.updateTasks:
            var secondaryInfo = ""
            if numberOfRemainingTasks == 0 {
                secondaryInfo = LabelStrings.noTasksRemaining
            } else if numberOfRemainingTasks == 1 {
                secondaryInfo = LabelStrings.oneTaskRemaining
            } else {
                secondaryInfo = String.localizedStringWithFormat(LabelStrings.numberOfRemainingTasks, numberOfRemainingTasks)
            }
            message.md.set(value: secondaryInfo, forKey: Keys.secondaryInformation)
        case .none:
            message.md.set(value: "", forKey: Keys.secondaryInformation)
        }
        message.md.set(value: Event.shared.localEventId, forKey: Keys.localEventId)
    }
    
    func fetchBubbleInformation(for message: MSMessage) -> BubbleInfo {
        var bubbleInfo = BubbleInfo()
        if let eventName = message.md.string(forKey: Keys.eventName) {
            bubbleInfo.eventName = eventName
        }
        if let eventDate = message.md.string(forKey: Keys.eventDate) {
            bubbleInfo.eventDate = eventDate
        }
        if let mainInformation = message.md.string(forKey: Keys.mainInformation) {
            bubbleInfo.mainInformation = mainInformation
        }
        if let secondaryInformation = message.md.string(forKey: Keys.secondaryInformation) {
            bubbleInfo.secondaryInformation = secondaryInformation
        }
        if let localEventId = message.md.string(forKey: Keys.localEventId) {
            Event.shared.localEventId = localEventId
            if let userStatus = CloudManager.shared.retrieveUserInfoOnCloud(key: localEventId) {
                bubbleInfo.userStatus = userStatus
            }
        }
        return bubbleInfo
    }
    
    private func prepareAlternateLayout() -> MSMessageTemplateLayout {
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: Images.standardBackground)
        layout.imageTitle = Event.shared.dinnerName
        layout.imageSubtitle = Event.shared.dinnerDate
        layout.caption = LabelStrings.caption
        return layout
    }
    
    private func retrieveUserStatus(_ combinedStrings: [String], localIdentifier: String?) -> Invitation {
        var statusDictionary = [String : String]()
        combinedStrings.forEach { combinedString in
            let components = combinedString.components(separatedBy: "+")
            statusDictionary[components[0]] = components[1]
        }
        let cloudUserId = CloudManager.shared.retrieveUserIdOnCloud() ?? ""
        var potentialStatus = ""
        statusDictionary.forEach { (key, value) in
            if key == cloudUserId || key == localIdentifier {
                potentialStatus = value
            }
        }
        let status = Invitation(rawValue: potentialStatus)
        return status ?? .pending
    }
}
