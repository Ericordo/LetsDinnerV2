//
//  MessagesViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 02/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import Messages
import Firebase
import RealmSwift
import FirebaseAuth

class MessagesViewController: MSMessagesAppViewController {
        
    private var newNameRequested = false
    private var isProgressBarVCInitiated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "")
        self.view.backgroundColor = .backgroundColor
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        //        Database.database().isPersistenceEnabled = true
        
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        do {
            _ = try Realm()
        } catch {
            print("ERROR", error, error.localizedDescription)
        }

//        CloudManager.shared.checkUserCloudStatus {
//                    CloudManager.shared.retrieveProfileInfo()
//                }
        CloudManager.shared.retrieveProfileInfo()
        
        // Configure your testing condition in testManager
        if testManager.isTesting {
            overrideEnvironment()
        }
    }

    override func viewWillLayoutSubviews() {
        let gradientLayers = view.layer.sublayers?.compactMap { $0 as? CAGradientLayer }
        gradientLayers?.first?.frame = view.bounds

    }
    
    // MARK: - Conversation Handling
    
    
    override func willBecomeActive(with conversation: MSConversation) {
        
        if presentationStyle == .transcript {
            presentTranscriptView(for: conversation)
        } else {
            presentViewController(for: conversation, with: presentationStyle)
        }
        
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didBecomeActive(with conversation: MSConversation) {
        // After you just created event, this session will run one more time, after this, you will run message sent
        
        guard let currentUserUid = activeConversation?.localParticipantIdentifier.uuidString else { return }
        
        if CloudManager.shared.retrieveUserIdOnCloud() == nil {
            CloudManager.shared.saveUserInfoOnCloud(currentUserUid, key: Keys.userUid)
        }
        
        // Internal checking
        func userHasReplied() -> Bool {
            if currentUserUid == Event.shared.hostIdentifier {
                print("I am the Host")
                return true
            } else {
                for participant in Event.shared.participants {
                    if currentUserUid == participant.identifier {
                        if participant.hasAccepted != .pending {
                            return true
                        }
                    }
                }
            }
            return false
        }
        
        // Everytime terminate the app, it will forget the event.shared.currentUser is Nil
        
        // Check if it is a new event
        if Event.shared.currentUser == nil {
            
            // Initiate as a new user (Here is the only place to have a pending status)
            // Need to guard when user has already been in the group
            guard userHasReplied() == false else { return }
            var identifier = String()
            if let cloudID = CloudManager.shared.retrieveUserIdOnCloud(), !cloudID.isEmpty {
                identifier = cloudID
            } else {
                identifier = currentUserUid
            }
            
            Event.shared.currentUser = User(identifier: identifier,
                                            fullName: defaults.username,
                                            hasAccepted: .pending)
        } else {
            
            // Guard first time to create event
            guard !Event.shared.hostIdentifier.isEmpty else { return }
            print("hostID: \(Event.shared.hostIdentifier)")
            
        }
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
        print("Resign Active State")
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        
        // Auto Accept the dinner for host creating event
        guard let currentUser = Event.shared.currentUser else {return}
        
        // First Time Create Event session
        if !Event.shared.hostIsRegistered {
            if !Event.shared.participants.contains(where: { $0.identifier == Event.shared.currentUser?.identifier }) {
                // To identify the first participant (Host)
                currentUser.hasAccepted = .accepted
                Event.shared.hostIsRegistered = true
            }
        }
        
        // Update Invitation State
        if Event.shared.statusNeedUpdate {
            Event.shared.updateAcceptStateToFirebase(hasAccepted: currentUser.hasAccepted)
            Event.shared.statusNeedUpdate = false
        }

        if !Event.shared.eventCreation {
            if Event.shared.servingsNeedUpdate {
                Event.shared.updateFirebaseServings()
                Event.shared.updateFirebaseTasks()
            } else if Event.shared.tasksNeedUpdate {
                Event.shared.updateFirebaseTasks()
            }
        }
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
        #warning("If eventCreation, delete event on firebase")
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WillTransition"), object: nil)
        
        // For Hiding ProgressBar
        let presentationStyle:[String: Int] = ["style": Int(presentationStyle.rawValue)]

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProgressBarWillTransition"), object: nil, userInfo:  presentationStyle)
        
//        if self.view.layer.sublayers!.count < 1 {
//            self.view.addBackground()
//        }
        
        removeViewController()
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    // MARK: - Present View Controller
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        
        // Remove any child view controllers that have been presented.
        removeViewController()
        
        let controller: UIViewController
        
        if presentationStyle == .compact {
            
            if Event.shared.dinnerName.isEmpty {
                controller = instantiateInitialViewController()
            } else {
                controller = instantiateIdleViewController()
            }
            
        } else {
            
            // Expanded Style
            if defaults.username.isEmpty || newNameRequested {
                newNameRequested = false
                controller = instantiateRegistrationViewController(previousStep: StepStatus.currentStep ?? StepTracking.eventSummaryVC)
            } else {
                
                if conversation.selectedMessage?.url != nil {
                    guard let message = conversation.selectedMessage else { return }
                    Event.shared.currentSession = message.session
                    Event.shared.parseMessage(message: message)
                    
                    if Event.shared.eventIsExpired || Event.shared.isCancelled {
                        controller = instantiateExpiredEventViewController()
                    } else {
                        controller = instantiateEventSummaryViewController()
                    }
                    
                } else {
                    switch StepStatus.currentStep {
                    case .initialVC:
                        controller = instantiateNewEventViewController()
                    case .registrationVC:
                        controller = instantiateRegistrationViewController(previousStep: StepStatus.currentStep!)
                    case .newEventVC:
                        controller = instantiateNewEventViewController()
                    case .recipesVC:
                        controller = instantiateRecipesViewController()
                    case .recipeDetailsVC:
                        controller = instantiateRecipesViewController()
                    case .managementVC:
                        controller = instantiateManagementViewController()
                    case .eventDescriptionVC:
                        controller = instantiateEventDescriptionViewController()
                    case .reviewVC:
                        controller = instantiateReviewViewController()
                    case .eventSummaryVC:
                        controller = instantiateEventSummaryViewController()
                    case .tasksListVC:
                        controller = instantiateTasksListViewController()
                    case .eventInfoVC:
                        controller = instantiateEventInfoViewController()
                    case .none:
                        controller = instantiateNewEventViewController()
                    case .expiredEventVC:
                        controller = instantiateExpiredEventViewController()
                        
                    }
                }
                
            }
        }
        
        self.addChildViewController(controller: controller)
        

    }
    
    // MARK: Transcript View
    
    private func presentTranscriptView(for conversation: MSConversation) {
        let bubbleManager = BubbleManager()
        guard conversation.selectedMessage?.url != nil else { return }
        guard let message = conversation.selectedMessage else { return }
        let bubbleInfo = bubbleManager.fetchBubbleInformation(for: message)
        let transcriptView = EventTranscriptView(bubbleInfo: bubbleInfo,
                                                 delegate: self)
        view.addSubview(transcriptView)
        transcriptView.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstant: CGFloat = conversation.isSelectedMessageFromMe ? 0 : 1
        let trailingConstant: CGFloat = conversation.isSelectedMessageFromMe ? -1 : 0
        NSLayoutConstraint.activate([
            transcriptView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingConstant),
            transcriptView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingConstant),
            transcriptView.topAnchor.constraint(equalTo: view.topAnchor),
            transcriptView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 300, height: 151)
    }
    
    // MARK: Controller Animation
    func addChildViewController(controller: UIViewController, transition: VCTransitionDirection = .noTransition) {
        
        addChild(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Transition animation
        if transition != .noTransition {
            controller.view.layer.add(configureTransitionAnimation(transition: transition), forKey: nil)
        }
        
//        self.view.insertSubview(controller.view, at: 1)
        view.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        controller.didMove(toParent: self)
        
    }
    
    private func configureTransitionAnimation(transition: VCTransitionDirection) -> CATransition {
        let transitionAnimation = CATransition()
        transitionAnimation.duration = 0.3
        transitionAnimation.type = CATransitionType.push
        
        switch transition {
        case .VCGoBack:
            transitionAnimation.subtype = CATransitionSubtype.fromLeft
        case .VCGoForward:
            transitionAnimation.subtype = CATransitionSubtype.fromRight
        case .VCGoUp:
            transitionAnimation.subtype = CATransitionSubtype.fromTop
        case .VCGoDown:
            transitionAnimation.subtype = CATransitionSubtype.fromBottom
        default:
            break
        }
        return transitionAnimation
    }
        
    private func removeViewController(transition: VCTransitionDirection = .noTransition) {
        
        var timeDelay = 0.0
        
        for child in children {
            
            if transition != .noTransition {
                timeDelay = 0.3
                child.configureDismissVCTransitionAnimation(transition: transition)
            }
            
            UIView.transition(with: self.view,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
            
            child.willMove(toParent: nil)

            DispatchQueue.main.asyncAfter(deadline: .now() + timeDelay) { //
                child.view.removeFromSuperview()
                child.removeFromParent()
            }

        }
    }
    
    private func removeAllSubviews() {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    // MARK: Init the VC
    
    private func instantiateProgressViewController() -> UIViewController {
        let controller = ProgressViewController()
        return controller
    }
    
    private func instantiateInitialViewController() -> UIViewController {
        let controller = InitialViewController(nibName: VCNibs.initialViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateIdleViewController() -> UIViewController {
        let controller = IdleViewController(nibName: VCNibs.idleViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateRegistrationViewController(previousStep: StepTracking) -> UIViewController {
        let controller = RegistrationViewController(viewModel: RegistrationViewModel(),
                                                       previousStep: previousStep,
                                                       delegate: self)
        return controller
    }
    
    private func instantiateNewEventViewController() -> UIViewController {
        let controller = NewEventViewController(viewModel: NewEventViewModel())
        controller.delegate = self
        return controller
    }
    
    private func instantiateRecipesViewController() -> UIViewController {
        let controller = RecipesViewController(viewModel: RecipesViewModel())
        controller.delegate = self
        return controller
    }
    
    private func instantiateManagementViewController() -> UIViewController {
        let controller = ManagementViewController(viewModel: ManagementViewModel())
        controller.delegate = self
        return controller
    }
    
    private func instantiateEventDescriptionViewController() -> UIViewController {
        let controller = EventDescriptionViewController(viewModel: EventDescriptionViewModel())
        controller.delegate = self
        return controller
    }
    
    private func instantiateReviewViewController() -> UIViewController {
        let controller = ReviewViewController(viewModel: ReviewViewModel())
        controller.delegate = self
        return controller 
    }
    
    private func instantiateEventSummaryViewController() -> UIViewController {
        let controller = EventSummaryViewController(viewModel: EventSummaryViewModel())
        controller.delegate = self
        return controller
    }
    
    private func instantiateExpiredEventViewController() -> UIViewController {
        let controller = ExpiredEventViewController(delegate: self)
        return controller
    }
    
    private func instantiateTasksListViewController() -> UIViewController {
        let controller = TasksListViewController(viewModel: TasksListViewModel(), delegate: self)
        return controller
    }
    
    private func instantiateEventInfoViewController() -> UIViewController {
        let controller = EventInfoViewController(delegate: self)
        return controller
    }
    
    private func sendMessage(message: MSMessage) {
        guard let conversation = activeConversation else { fatalError("Expected an active conversation") }
        conversation.insert(message) {error in
            if let error = error {
                print(error)
            }
        }
        self.dismiss()
    }
    
    private func sendMessageDirectly(message: MSMessage) {
        guard let conversation = activeConversation else { fatalError("Expected an active conversation") }
        conversation.send(message) {error in
            if let error = error {
                print(error)
            }
        }
        self.dismiss()
    }
}

// MARK: Delegations

extension MessagesViewController: InitialViewControllerDelegate {
    func initialVCDidTapStartButton(controller: InitialViewController) {
        requestPresentationStyle(.expanded)
        activeConversation?.selectedMessage?.url = nil
        Event.shared.resetEvent()
    }
    
    func initialVCDidTapInfoButton(controller: InitialViewController) {
        newNameRequested = true
        requestPresentationStyle(.expanded)
    }
}

extension MessagesViewController: IdleViewControllerDelegate {
    func idleVCDidTapContinue(controller: IdleViewController) {
        requestPresentationStyle(.expanded)
    }
    
    func idleVCDidTapNewDinner(controller: IdleViewController) {
        Event.shared.resetEvent()
        activeConversation?.selectedMessage?.url = nil
        StepStatus.currentStep = .newEventVC
        requestPresentationStyle(.expanded)
    }
    
    func idleVCDidTapProfileButton(controller: IdleViewController) {
        newNameRequested = true
        requestPresentationStyle(.expanded)
    }
}

extension MessagesViewController: RegistrationViewControllerDelegate {
    func registrationVCDidTapSaveButton(previousStep: StepTracking) {
        guard let conversation = activeConversation else { fatalError("Expected an active conversation") }
        if previousStep == .newEventVC {
            StepStatus.currentStep = .newEventVC
        } else if previousStep == .initialVC {
            StepStatus.currentStep = .newEventVC
        } else if previousStep == .eventSummaryVC {
            StepStatus.currentStep = .eventSummaryVC
        } else {
            StepStatus.currentStep = .newEventVC
        }
        presentViewController(for: conversation, with: .expanded)
    }
    
    func registrationVCDidTapCancelButton() {
        newNameRequested = false
        requestPresentationStyle(.compact)
    }
}

extension MessagesViewController: NewEventViewControllerDelegate {

    func eventDescriptionVCDidTapFinish(controller: NewEventViewController) {
        let controller = instantiateReviewViewController()
        removeViewController()
        addChildViewController(controller: controller)
    }

    func newEventVCDdidTapProfile(controller: NewEventViewController) {
        let controller = instantiateRegistrationViewController(previousStep: .newEventVC)
        removeViewController()
        addChildViewController(controller: controller)
    }

    func newEventVCDidTapNext(controller: NewEventViewController) {
        let controller = instantiateRecipesViewController()
        removeViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
}

extension MessagesViewController: RecipesViewControllerDelegate {
    func recipeVCDidTapNext() {
        let controller = instantiateManagementViewController()
        removeViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
    
    func recipeVCDidTapPrevious() {
        let controller = instantiateNewEventViewController()
        removeViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
}

extension MessagesViewController: ManagementViewControllerDelegate {
    func managementVCDidTapBack() {
        let controller = instantiateRecipesViewController()
        removeViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
    func managementVCDdidTapNext() {
        let controller = instantiateEventDescriptionViewController()
        removeViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
}

extension MessagesViewController: EventDescriptionViewControllerDelegate {
    func eventDescriptionVCDidTapPrevious(controller: EventDescriptionViewController) {
        let controller = instantiateManagementViewController()
        removeViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
    func eventDescriptionVCDidTapFinish(controller: EventDescriptionViewController) {
        let controller = instantiateReviewViewController()
        removeViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
}

extension MessagesViewController: ReviewViewControllerDelegate {
    func reviewVCDidTapPrevious() {
        let controller = instantiateEventDescriptionViewController()
        removeViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
    func reviewVCDidTapSend() {
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        Event.shared.summary = "\(defaults.username) is inviting you to an event!"
        Event.shared.eventCreation = true
        let message = Event.shared.prepareMessage(session: currentSession,
                                                  eventCreation: Event.shared.eventCreation,
                                                  action: .createEvent)
        if Event.shared.firebaseEventUid == "error" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UploadError"), object: nil)
        } else {
            CloudManager.shared.saveUserInfoOnCloud(Invitation.accepted.rawValue, key: Event.shared.localEventId)
            sendMessage(message: message)
        }
    }
    
    func reviewVCBackToManagementVC() {
        let controller = instantiateManagementViewController()
        removeViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
}

extension MessagesViewController: EventSummaryViewControllerDelegate {
    func eventSummaryVCDidCancelEvent(controller: EventSummaryViewController) {
        Event.shared.cancelFirebaseEvent()
        Event.shared.summary = "\(defaults.username) canceled the event."
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = Event.shared.prepareMessage(session: currentSession,
                                                  eventCreation: Event.shared.eventCreation,
                                                  action: .cancelEvent)
        sendMessageDirectly(message: message)
    }
    
    func eventSummaryVCDidUpdateDate(date: Double, controller: EventSummaryViewController) {
        Event.shared.updateFirebaseDate(date)
        Event.shared.summary = "\(defaults.username) changed the date!"
        Event.shared.eventCreation = false
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = Event.shared.prepareMessage(session: currentSession,
                                                  eventCreation: Event.shared.eventCreation,
                                                  action: .rescheduleEvent)
        sendMessageDirectly(message: message)
    }
    
    
    func eventSummaryVCOpenTasksList(controller: EventSummaryViewController) {
        let controller = instantiateTasksListViewController()
        removeViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
    
    func eventSummaryVCDidAnswer(hasAccepted: Invitation, controller: EventSummaryViewController) {
        // Instant MessageUI update
        if hasAccepted == .accepted {
            Event.shared.summary = defaults.username + AlertStrings.acceptedInvitation
        } else if hasAccepted == .declined {
            Event.shared.summary = defaults.username + AlertStrings.declinedInvitation
        }
        
        Event.shared.currentUser?.hasAccepted = hasAccepted
        CloudManager.shared.saveUserInfoOnCloud(hasAccepted.rawValue, key: Event.shared.localEventId)
        Event.shared.eventCreation = false
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = Event.shared.prepareMessage(session: currentSession,
                                                  eventCreation: Event.shared.eventCreation,
                                                  action: .answerInvitation)
        sendMessage(message: message)
    }
    
    func eventSummaryVCOpenEventInfo(controller: EventSummaryViewController) {
        let controller = instantiateEventInfoViewController()
        removeViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
}

extension MessagesViewController: TasksListViewControllerDelegate {
    func tasksListVCDidTapBackButton() {
        let controller = instantiateEventSummaryViewController()
              removeViewController(transition: .VCGoBack)
              addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
    func tasksListVCDidTapSubmit() {
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        Event.shared.eventCreation = false
        let message = Event.shared.prepareMessage(session: currentSession,
                                                  eventCreation: Event.shared.eventCreation,
                                                  action: .updateTasks)
        sendMessage(message: message)
    }
}

extension MessagesViewController: EventInfoViewControllerDelegate {
    func eventInfoVCDidTapBackButton() {
        let controller = instantiateEventSummaryViewController()
        removeViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
}

extension MessagesViewController: ExpiredEventViewControllerDelegate {
    func expiredEventVCDidTapCreateNewEvent() {
        Event.shared.resetEvent()
        let controller = instantiateNewEventViewController()
        removeViewController()
        addChildViewController(controller: controller)
    }
}

extension MessagesViewController: EventTranscriptViewDelegate {
    func didTapBubble() {
        self.requestPresentationStyle(.expanded)
    }
}

// MARK: For Test Only
extension MessagesViewController {
    private func overrideEnvironment() {
        if testManager.isDarkModeOn {
            testManager.darkModeOn(view: self)
        }
    }
}
