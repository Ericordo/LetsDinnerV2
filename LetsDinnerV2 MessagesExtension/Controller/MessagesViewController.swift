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
    private var progressBarHeight: CGFloat = 0
    private var needsProgressBar = false {
        didSet { progressBarHeight = needsProgressBar ? 2 : 0 }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "")
        self.view.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        
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

//        if #available(iOSApplicationExtension 13.0, *) {
//            overrideUserInterfaceStyle = .dark
//        }
    }

    override func viewDidLayoutSubviews() {
        let gradientLayers = view.layer.sublayers?.compactMap { $0 as? CAGradientLayer }
        gradientLayers?.first?.frame = view.bounds
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        presentViewController(for: conversation, with: presentationStyle)
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
                print("I am Host")
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
        
        // Call When update on tasklistVC
        if Event.shared.tasksNeedUpdate {
            // Need to identify all situation for using updateFireBaseTask
            Event.shared.updateFirebaseTasks()
        }
        
        if Event.shared.servingsNeedUpdate {
            Event.shared.updateFirebaseServings()
        }
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
        
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WillTransition"), object: nil)
        removeChildViewController()
        
        
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        presentViewController(for: conversation, with: presentationStyle)
        print(#function)
    }
    
    // MARK: - Present View Controller
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        
        // Remove any child view controllers that have been presented.
        removeChildViewController()
        
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
        addChildViewController(controller: controller)
        
        
    }
    

    func addChildViewController(controller: UIViewController, transition: VCTransitionDirection = .noTransition) {
        
        addChild(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Transition animation
        if transition != .noTransition {
            controller.view.layer.add(configureTransitionAnimation(transition: transition), forKey: nil)
        }
        
        view.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor, constant: progressBarHeight),
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
    
    private func addProgressViewController() {
        let controller = ProgressViewController(nibName: VCNibs.progressViewController, bundle: nil)
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(controller.view)
        
        needsProgressBar = true
        
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
        
    private func removeChildViewController(transition: VCTransitionDirection = .noTransition) {
        
        var timeDelay = 0.0
        
        for child in children {
            
            if transition != .noTransition {
                timeDelay = 0.25
                child.configureDismissVCTransitionAnimation(transition: transition)
            }
            child.willMove(toParent: nil)
                                    
            UIView.transition(with: self.view,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeDelay) { //
                child.view.removeFromSuperview()
                child.removeFromParent()
            }

        }
            
        
    }
    
    private func removeProgressViewController() {
        if self.children.count > 0 {
            let viewControllers:[UIViewController] = self.children
            
            for viewController in viewControllers {
                if viewController is ProgressViewController {
                    viewController.willMove(toParent: nil)
                    viewController.view.removeFromSuperview()
                    viewController.removeFromParent()
                }
            }
        }
    }
    
    // MARK: Init the VC
    
    private func instantiateProgressViewController() -> UIViewController {
        let controller = ProgressViewController(nibName: VCNibs.progressViewController, bundle: nil)
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
        needsProgressBar = false
        // Visually correct but have extra layers
        
        let controller = RegistrationViewController(nibName: VCNibs.registrationViewController, bundle: nil)
        controller.previousStep = previousStep
        controller.delegate = self
        return controller
    }
    
    private func instantiateNewEventViewController() -> UIViewController {
        if !needsProgressBar {
            addProgressViewController()
        }
        
        let controller = NewEventViewController(nibName: VCNibs.newEventViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateRecipesViewController() -> UIViewController {
        if !needsProgressBar {
            addProgressViewController()
        }
        
        let controller = RecipesViewController(nibName: VCNibs.recipesViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateManagementViewController() -> UIViewController {
        if !needsProgressBar {
            addProgressViewController()
        }
        
        let controller = ManagementViewController(nibName: VCNibs.managementViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateEventDescriptionViewController() -> UIViewController {
        if !needsProgressBar {
            addProgressViewController()
        }
        
        let controller = EventDescriptionViewController(nibName: VCNibs.eventDescriptionViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateReviewViewController() -> UIViewController {
        if !needsProgressBar {
            addProgressViewController()
        }
        
        let controller = ReviewViewController(nibName: VCNibs.reviewViewController, bundle: nil)
        controller.delegate = self
        return controller 
    }
    
    private func instantiateEventSummaryViewController() -> UIViewController {
        if !needsProgressBar { // I need the White Background
            addProgressViewController()
            progressBarHeight = 0
        }
        
        let controller = EventSummaryViewController(nibName: VCNibs.eventSummaryViewController, bundle: nil)
        controller.delegate = self
        print(Event.shared.eventIsExpired)
        return controller
    }
    
    private func instantiateExpiredEventViewController() -> UIViewController {
        let controller = ExpiredEventViewController(nibName: VCNibs.expiredEventViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateTasksListViewController() -> UIViewController {
        let controller = TasksListViewController(nibName: VCNibs.tasksListViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateEventInfoViewController() -> UIViewController {
        let controller = EventInfoViewController(nibName: VCNibs.eventInfoViewController, bundle: nil)
        controller.delegate = self
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
    func registrationVCDidTapSaveButton(controller: RegistrationViewController, previousStep: StepTracking) {
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
    
    func registrationVCDidTapCancelButton(controller: RegistrationViewController) {
        newNameRequested = false
        requestPresentationStyle(.compact)
    }
}

extension MessagesViewController: NewEventViewControllerDelegate {

    func eventDescriptionVCDidTapFinish(controller: NewEventViewController) {
        let controller = instantiateReviewViewController()
        removeChildViewController()
        addChildViewController(controller: controller)
    }
    
    func newEventVCDdidTapProfile(controller: NewEventViewController) {
        let controller = instantiateRegistrationViewController(previousStep: .newEventVC)
        removeChildViewController()
        addChildViewController(controller: controller) 
    }
    
    func newEventVCDidTapNext(controller: NewEventViewController) {
        let controller = instantiateRecipesViewController()
        removeChildViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
}

extension MessagesViewController: RecipesViewControllerDelegate {
    func recipeVCDidTapNext(controller: RecipesViewController) {
        let controller = instantiateManagementViewController()
        removeChildViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
    
    func recipeVCDidTapPrevious(controller: RecipesViewController) {
        let controller = instantiateNewEventViewController()
        removeChildViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
}

extension MessagesViewController: ManagementViewControllerDelegate {
    func managementVCDidTapBack(controller: ManagementViewController) {
        let controller = instantiateRecipesViewController()
        removeChildViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
    func managementVCDdidTapNext(controller: ManagementViewController) {
        let controller = instantiateEventDescriptionViewController()
        removeChildViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
}

extension MessagesViewController: EventDescriptionViewControllerDelegate {
    func eventDescriptionVCDidTapPrevious(controller: EventDescriptionViewController) {
        let controller = instantiateManagementViewController()
        removeChildViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
    func eventDescriptionVCDidTapFinish(controller: EventDescriptionViewController) {
        let controller = instantiateReviewViewController()
        removeChildViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
}

extension MessagesViewController: ReviewViewControllerDelegate {
    func reviewVCDidTapPrevious(controller: ReviewViewController) {
        let controller = instantiateEventDescriptionViewController()
        removeChildViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
    func reviewVCDidTapSend(controller: ReviewViewController) {
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = Event.shared.prepareMessage(session: currentSession, eventCreation: true)
        if Event.shared.firebaseEventUid == "error" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UploadError"), object: nil)
        } else {
            sendMessage(message: message)
        }
    }
    
    func reviewVCBackToManagementVC(controller: ReviewViewController) {
        let controller = instantiateManagementViewController()
        removeChildViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
}

extension MessagesViewController: EventSummaryViewControllerDelegate {
    func eventSummaryVCDidCancelEvent(controller: EventSummaryViewController) {
        Event.shared.cancelFirebaseEvent()
        Event.shared.summary = "\(defaults.username) canceled the event."
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = Event.shared.prepareMessage(session: currentSession, eventCreation: false)
        sendMessageDirectly(message: message)
    }
    
    func eventSummaryVCDidUpdateDate(date: Double, controller: EventSummaryViewController) {
        Event.shared.updateFirebaseDate(date)
        Event.shared.summary = "\(defaults.username) changed the date!"
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = Event.shared.prepareMessage(session: currentSession, eventCreation: false)
        sendMessageDirectly(message: message)
    }
    
    
    func eventSummaryVCOpenTasksList(controller: EventSummaryViewController) {
        let controller = instantiateTasksListViewController()
        removeChildViewController()
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
    
    func eventSummaryVCDidAnswer(hasAccepted: Invitation, controller: EventSummaryViewController) {
        // Instant MessageUI update
        if hasAccepted == .accepted {
            Event.shared.summary = defaults.username + MessagesToDisplay.acceptedInvitation
        } else if hasAccepted == .declined {
            Event.shared.summary = defaults.username + MessagesToDisplay.declinedInvitation
        }
        
        Event.shared.currentUser?.hasAccepted = hasAccepted
        
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = Event.shared.prepareMessage(session: currentSession, eventCreation: false)
        sendMessage(message: message)
    }
    
    func eventSummaryVCOpenEventInfo(controller: EventSummaryViewController) {
        let controller = instantiateEventInfoViewController()
        removeChildViewController(transition: .VCGoForward)
        addChildViewController(controller: controller, transition: .VCGoForward)
    }
}

extension MessagesViewController: TasksListViewControllerDelegate {
    func tasksListVCDidTapBackButton(controller: TasksListViewController) {
        let controller = instantiateEventSummaryViewController()
              removeChildViewController(transition: .VCGoBack)
              addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
    func tasksListVCDidTapSubmit(controller: TasksListViewController) {
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = Event.shared.prepareMessage(session: currentSession, eventCreation: false)
        sendMessage(message: message)
    }
}

extension MessagesViewController: EventInfoViewControllerDelegate {
    func eventInfoVCDidTapBackButton(controller: EventInfoViewController) {
        let controller = instantiateEventSummaryViewController()
        removeChildViewController(transition: .VCGoBack)
        addChildViewController(controller: controller, transition: .VCGoBack)
    }
    
}

extension MessagesViewController: ExpiredEventViewControllerDelegate {
    func expiredEventVCDidTapCreateNewEvent(controller: ExpiredEventViewController) {
        Event.shared.resetEvent()
        let controller = instantiateNewEventViewController()
        removeChildViewController()
        addChildViewController(controller: controller)
    }
}
