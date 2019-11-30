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

class MessagesViewController: MSMessagesAppViewController {
    
    var newNameRequested = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
        
        if FirebaseApp.app() == nil {
               FirebaseApp.configure()
        }
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        presentViewController(for: conversation, with: presentationStyle)
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didBecomeActive(with conversation: MSConversation) {
        guard let currentUserUid = activeConversation?.localParticipantIdentifier.uuidString else { return }
        
        func isAlreadyReply() -> Bool {
                    if currentUserUid == Event.shared.hostIdentifier {
                        print("Host")
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
        
        // After you just created event, this will run on more time, then you will run message sent
        //Everytime terminate the app, it will forget the event.shared.currentUser is Nil
        
        // Check if it is a new event
        if Event.shared.currentUser == nil {
            
            // Need to guard when user already in the group
            guard isAlreadyReply() == false else { return }
            
            // Initiate a new user
            Event.shared.currentUser = User(identifier: currentUserUid,
                                            fullName: defaults.username,
                                            hasAccepted: .pending)
    
        } else {
            
            // Guard first time to create event
            guard !Event.shared.hostIdentifier.isEmpty else { return }
            
            print("hostID: \(Event.shared.hostIdentifier)")

            if isAlreadyReply() == false {
                print("Test")
            }
        
        }
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Auto Accept the dinner for host creating event
        guard let currentUser = Event.shared.currentUser else {return}
        
        if !Event.shared.isHostRegistered {
            // Create Event session
            if !Event.shared.participants.contains(where: { $0.identifier == Event.shared.currentUser?.identifier }) {
            
            //Testing case: accept or decline
            currentUser.hasAccepted = .accepted
            
//            Event.shared.hostIdentifier = currentUser.identifier
            Event.shared.isHostRegistered = true

            }
        } else {
            Event.shared.updateFirebaseTasks()
        }
        
        Event.shared.updateAcceptStateToFirebase(hasAccepted: currentUser.hasAccepted)
    
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        removeAllChildViewControllers()
        
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
        removeAllChildViewControllers()
        
        let controller: UIViewController
        
        if presentationStyle == .compact {
            if Event.shared.dinnerName.isEmpty {
                controller = instantiateInitialViewController()
            } else {
                controller = instantiateIdleViewController()
            }
        } else {
            //Expanded Style
            if defaults.username.isEmpty || newNameRequested {
                newNameRequested = false
                controller = instantiateRegistrationViewController(previousStep: StepStatus.currentStep!)
            } else {
                if conversation.selectedMessage?.url != nil {
                    guard let message = conversation.selectedMessage else { return }
                    Event.shared.currentSession = message.session
                    Event.shared.parseMessage(message: message)
                    controller = instantiateEventSummaryViewController()
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
                    }
//                    if Event.shared.dinnerName.isEmpty {
//                        controller = instantiateNewEventViewController()
//                    } else if Event.shared.selectedRecipes.isEmpty {
//                        controller = instantiateRecipesViewController()
//                    } else if Event.shared.eventDescription.isEmpty {
//                        controller = instantiateEventDescriptionViewController()
//                    } else {
//                        controller = instantiateNewEventViewController()
//                    }
                }
                
            }
        }
        
        addChildViewController(controller: controller)
    }
    
    func addChildViewController(controller: UIViewController) {
        addChild(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        controller.didMove(toParent: self)
    }
    
    private func removeAllChildViewControllers() {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
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
        let controller = RegistrationViewController(nibName: VCNibs.registrationViewController, bundle: nil)
        controller.previousStep = previousStep
        controller.delegate = self
        return controller
    }
    
    private func instantiateNewEventViewController() -> UIViewController {
        let controller = NewEventViewController(nibName: VCNibs.newEventViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateRecipesViewController() -> UIViewController {
        let controller = RecipesViewController(nibName: VCNibs.recipesViewController, bundle: nil)
        controller.delegate = self
         return controller
     }
    
    private func instantiateManagementViewController() -> UIViewController {
        let controller = ManagementViewController(nibName: VCNibs.managementViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
//    private func instantiateEventDescriptionViewControllerOld() -> UIViewController {
//        let controller = EventDescriptionViewControllerBis(nibName: VCNibs.eventDescriptionViewControllerOld, bundle: nil)
//        controller.delegate = self
//        return controller
//    }
    
    private func instantiateEventDescriptionViewController() -> UIViewController {
        let controller = EventDescriptionViewController(nibName: VCNibs.eventDescriptionViewController, bundle: nil)
        controller.delegate = self
        return controller
    }
    
    private func instantiateReviewViewController() -> UIViewController {
        let controller = ReviewViewController(nibName: VCNibs.reviewViewController, bundle: nil)
        controller.delegate = self
        return controller 
    }
    
    private func instantiateEventSummaryViewController() -> UIViewController {
        let controller = EventSummaryViewController(nibName: VCNibs.eventSummaryViewController, bundle: nil)
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
}



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
        if previousStep == .newEventVC {
            StepStatus.currentStep = .newEventVC
            guard let conversation = activeConversation else { fatalError("Expected an active conversation") }
            presentViewController(for: conversation, with: .expanded)
        } else if previousStep == .initialVC {
            StepStatus.currentStep = .newEventVC
            guard let conversation = activeConversation else { fatalError("Expected an active conversation") }
            presentViewController(for: conversation, with: .expanded)
        } else {
            requestPresentationStyle(.compact)
        }
    }
    
    func registrationVCDidTapCancelButton(controller: RegistrationViewController) {
        newNameRequested = false
//          let controller = instantiateInitialViewController()
            requestPresentationStyle(.compact)
//              removeAllChildViewControllers()
//              addChildViewController(controller: controller)
    }
    
//    func registrationVCDidTapSaveButton(controller: RegistrationViewController) {
//        StepStatus.currentStep = .newEventVC
//        guard let conversation = activeConversation else { fatalError("Expected an active conversation") }
//        presentViewController(for: conversation, with: .expanded)
//    }
}

extension MessagesViewController: NewEventViewControllerDelegate {
    func newEventVCDdidTapProfile(controller: NewEventViewController) {
        let controller = instantiateRegistrationViewController(previousStep: .newEventVC)
        removeAllChildViewControllers()
        addChildViewController(controller: controller) 
    }
    
    func newEventVCDidTapNext(controller: NewEventViewController) {
        let controller = instantiateRecipesViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller) 
    }
}

extension MessagesViewController: RecipesViewControllerDelegate {
    func recipeVCDidTapNext(controller: RecipesViewController) {
        let controller = instantiateManagementViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
    
    func recipeVCDidTapPrevious(controller: RecipesViewController) {
        let controller = instantiateNewEventViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
}

extension MessagesViewController: ManagementViewControllerDelegate {
    func managementVCDidTapBack(controller: ManagementViewController) {
        let controller = instantiateRecipesViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
    
    func managementVCDdidTapNext(controller: ManagementViewController) {
        let controller = instantiateEventDescriptionViewController()
//        let controller = instantiateEventDescriptionViewControllerOld()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
    
    
}

extension MessagesViewController: EventDescriptionViewControllerDelegate {
    func eventDescriptionVCDidTapPrevious(controller: EventDescriptionViewController) {
        let controller = instantiateManagementViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
    
    func eventDescriptionVCDidTapFinish(controller: EventDescriptionViewController) {
//        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
//        let message = Event.shared.prepareMessage(session: currentSession, eventCreation: true)
//        sendMessage(message: message)
        let controller = instantiateReviewViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
}

extension MessagesViewController: EventDescriptionViewControllerDelegateOld {
    func eventDescriptionVCDidTapPrevious(controller: EventDescriptionViewControllerOld) {
        let controller = instantiateManagementViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
    
    func eventDescriptionVCDidTapFinish(controller: EventDescriptionViewControllerOld) {
//        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
//        let message = Event.shared.prepareMessage(session: currentSession, eventCreation: true)
//        sendMessage(message: message)
        let controller = instantiateReviewViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
}

extension MessagesViewController: ReviewViewControllerDelegate {
    func reviewVCDidTapPrevious(controller: ReviewViewController) {
        let controller = instantiateEventDescriptionViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
    
    func reviewVCDidTapSend(controller: ReviewViewController) {
        let currentSession = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = Event.shared.prepareMessage(session: currentSession, eventCreation: true)
        sendMessage(message: message)
    }
}

extension MessagesViewController: EventSummaryViewControllerDelegate {
    
    func eventSummaryVCOpenTasksList(controller: EventSummaryViewController) {
        let controller = instantiateTasksListViewController()
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
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
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
}

extension MessagesViewController: TasksListViewControllerDelegate {
    func tasksListVCDidTapBackButton(controller: TasksListViewController) {
        let controller = instantiateEventSummaryViewController()
              removeAllChildViewControllers()
              addChildViewController(controller: controller)
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
        removeAllChildViewControllers()
        addChildViewController(controller: controller)
    }
    
}
