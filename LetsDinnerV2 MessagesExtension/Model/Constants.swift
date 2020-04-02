//
//  Constants.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 02/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard

enum VCNibs {
    static let initialViewController = "InitialViewController"
    static let registrationViewController = "RegistrationViewController"
    static let newEventViewController = "NewEventViewController"
    static let recipesViewController = "RecipesViewController"
    static let recipeDetailsViewController = "RecipeDetailsViewController"
    static let managementViewController = "ManagementViewController"
    static let eventDescriptionViewControllerOld = "EventDescriptionViewControllerOld"
    static let eventDescriptionViewController = "EventDescriptionViewController"
    static let eventSummaryViewController = "EventSummaryViewController"
    static let tasksListViewController = "TasksListViewController"
    static let idleViewController = "IdleViewController"
    static let reviewViewController = "ReviewViewController"
    static let eventInfoViewController = "EventInfoViewController"
    static let progressViewController = "ProgressViewController"
    static let expiredEventViewController = "ExpiredEventViewController"
}

enum CellNibs {
    static let titleCell = "TitleCell"
    static let recipeCell = "RecipeCell"
    static let answerCell = "AnswerCell"
    static let answerDeclinedCell = "AnswerDeclinedCell"
    static let answerAcceptedCell = "AnswerAcceptedCell"
    static let infoCell = "InfoCell"
    static let descriptionCell = "DescriptionCell"
    static let taskSummaryCell = "TaskSummaryCell"
    static let userCell = "UserCell"
    static let calendarCell = "CalendarCell"
    static let taskCVCell = "TaskCVCell"
    static let taskCell = "TaskCell"
    static let userCVCell = "UserCVCell"
    static let taskManagementCell = "TaskManagementCell"
    static let recipeCVCell = "RecipeCVCell"
    static let sectionInputCell = "SectionInputCell"
    static let ingredientCell = "IngredientCell"
    static let cancelCell = "CancelCell"
    static let expiredEventCell = "ExpiredEventCell"
}

enum ApiKeys {
        static let appId =  "5dbeb10b"
        static let apiKey = "b92d6e0482b3e23150ef3060aec1fd31"
        static let apiKeySpoonacular = "123e94eacbbf40e497d48a0dd5b83189"
    // In case too many requests during testing
        static let backUpKey = "b07aca6301b44075ac9b4c9b09a2b3ac"
}

enum Keys {
    static let username = "username"
    static let profilePicUrl = "profilePicUrl"
    static let address = "address"
    static let measurementSystem = "measurementSystem"
//    static let accepted = "Accepted"
//    static let declined = "Declined"
    static let userUid = "userUid"
    static let onboardingComplete = "onboardingComplete"
    
}

enum MessagesToDisplay {
    // Add to Calenedar Alert
    static let calendarAlert = "This event was successfully added to your calendar."
    static let addToCalendarAlertTitle = "Add to calendar?"
    static let addToCalendarAlertMessage = "You can add this event to your calendar, to make sure you wont be running late!"
    
    // Accept Or Decline Alert
    static let acceptInviteAlert = "Please accept the invitation to manage the tasks."
    static let userHasDeclinedAlert = "You declined the invitation, you are not able to manage the tasks."
    static let acceptedInvitation = " accepted the invitation"
    static let declinedInvitation = " declined the invitation"
    
    // Cancel Event Alert
    static let cancelEventAlertTitle = "Cancel Event?"
    static let cancelEventAlertMessage = "You are about to cancel this event, this action will delete the invitation you created. Are you sure you want to cancel the event?"
    
    // Add Reminder Alert
    static let addToRemindersTitle = "Success"
    static let addToRemindersMessage = "Your tasks now added to Reminders!"
    static let remindersNoTaskTitle = "No updates"
    static let remindersNoTaskMessage = "You have no assigned task at the moment."
    
    static let eventExisted = "This event is already in your calendar"
    static let completed = "Completed"
    static let assignedToMyself = "Assigned to myself"
    static let noAssignment = "No Assignment"
    static let yes = "Yes"
    static let no = "No"
    
    // TaskListVC Alert
    static let unsubmittedTasks = "Dismiss changes?"
    static let submitQuestion = "You made changes in this list. Would you like to update it?"
    static let synchTitle = "Things synchronisation"
    static let synchMessage = "Changes made, can end up unsaved. Whoiever updates first, saves their changes."
    static let descriptionPrompt = "Please enter a description for your dinner."
    static let update = "Update"
    
    // Decline Event Alert
    static let declineEventAlertTitle = "Do you want to decline?"
    static let declineEventAlertMessage = "By declining, you won't able to participate the event."
    
    
    
    static let cancel = "Cancel"
    static let add = "Add"
    static let addThing = "Add a thing"
    static let thingToAdd = "Thing to add"
    static let noNetwork = "No Network"
    static let decodingFailed = "Failed to load recipes"
    static let requestLimit = "Too many requests"
    static let tryAgain = "You can try again in a minute"

}

enum LabelStrings {
    // StartVC
    static let getStarted = "Please enter your full name \n to get started."
    
    // NewEventVC
    static let host = "Host"
    static let eventInfo = "Event Info"
    static let date = "Date"
    static let location = "Location"
    static let addToCalendar = "Add to Calendar"
    
    // RecipeVC
    static let noRecipeTitle = "No recipes selected"
    static let noRecipeMessage = "Go back and Add something!"
    
    // CustomRecipeVC
    static let noCustomRecipeTitle = "No recipe"
    static let noCustomRecipeMessage = "You can create your own recipe!"
    
    // CreateRecipeVC
    static let cookingTipsPlaceholder = "Anything else you want to mention?"

    // ManagementVC
    static let noTaskTitle = "Nothing's missing? \nIn need of a helping hand?"
    static let noTaskMessage = "Things help you manage and organise your event. Missing any ingredients but it's too late to buy them? Let your invitees help you with that."
    static let noTaskMessage2 = "Start by tapping"
    
    // DescriptionVC
    static let whatsThePlan = "Would you like to add an invitation message? \nMore information? Anything else?"
    static let nothingToDo = "There is nothing to do!"
    
    // ReviewVC
    static let readyToSend = "Ready to send your invite?"
    static let readyToSend1 = "You're all set now! 💪 \nReady to send your invite?"
    static let readyToSend2 = "You're all set now! 🦾 \nReady to send your invite?"
    
    
    static let update = "Update"
    
    // SummaryEventVC
    static let invitationText = "Hey you received an invite! 🤩 \nDo you want to accept it?"
    static let acceptedLabel = "You've accepted the invitation"
    static let declinedLabel = "You've declined the invitation"
    
    
    // Reschedule
    static let rescheduleTitle = "Need to reschedule?"
    static let rescheduleText = "No problem, simply choose another date! 😅👌"
    static let selectNewDate = "Select a new date for your event:"

    
    // Past Event
    static let pastEventTitle = "Past Event"
    static let pastEventDescription = "Looks like this event is in the past but don't fret, cooking is still better together! Create a new event and send an invite! 🤩👍"
    
    // Canceled Event
    static let canceledEventTitle = "Canceled Event"
    static let canceledEventDescription = "Looks like the host has canceled this event but don't fret, cooking is still better together! Create a new event and send an invite! 🤩👍"
    
    // Welcome Screen
    static let welcome = NSLocalizedString("Welcome to\nLet's Dinner!", comment: "Welcome message")
    static let and = NSLocalizedString("and", comment: "and")
    static let termsService = NSLocalizedString("Terms of Service", comment: "Terms of Service")
    static let policy = NSLocalizedString("Privacy Policy", comment: "Privacy Policy")
    static let createEvents = NSLocalizedString("Create Events", comment: "in WelcomeVC")
    static let recipesAndTasks = NSLocalizedString("Recipes and Tasks", comment: "in WelcomeVC")
    static let neverLeave = NSLocalizedString("Never leave your Chat", comment: "in WelcomeVC")
    static let createEventsDescription = NSLocalizedString("Cooking is better together! Invite your loved ones and enjoy some quality time", comment: "in WelcomeVC")
    static let recipesAndTasksDescription = NSLocalizedString("Create your own or search among 360K+ recipes. Ingredients become tasks that your guests can pick to get everything ready!", comment: "in WelcomeVC")
    static let neverLeaveDescription = NSLocalizedString("Let's Dinner! will not flood your chat, so you can keep on chatting about that new video 😻🐶🍆💦", comment: "in WelcomeVC")
    static let letsGo = "Ok, Let's go!"
    
    // Message Bubble
    static let caption = NSLocalizedString("Tap to view this event", comment: "Message caption")
}

enum Images {
    static let chatIcon = "chatIcon"
    static let inviteIcon = "inviteIcon"
    static let thingsIcon = "thingsIcon"
    static let premiumBackground = "iMessageBackground"
    static let standardBackground = "bubbleBackground"
    static let chevronDisclosure = "chevronDisclosure"
}
