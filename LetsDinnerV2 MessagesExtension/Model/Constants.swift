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
    
    static let calendarAlert = "This event was successfully added to your calendar."
    static let acceptInviteAlert = "Please accept the invitation to manage the tasks."
    static let userHasDeclinedAlert = "You declined the invitation, you can not manage the tasks."
    static let acceptedInvitation = " accepted the invitation"
    static let declinedInvitation = " declined the invitation"
    static let eventExisted = "This event is already in your calendar"
    static let completed = "Completed"
    static let assignedToMyself = "Assigned to myself"
    static let noAssignment = "No Assignment"
    static let yes = "Yes"
    static let no = "No"
    static let unsubmittedTasks = "You have unsubmitted tasks."
    static let submitQuestion = "Do you want to submit them?"
    static let descriptionPrompt = "Please enter a description for your dinner."
    static let update = "Update"
    static let addToCalendarAlertTitle = "Add to calendar?"
    static let addToCalendarAlertMessage = "You can add this event to your calendar, to make sure you wont be running late!"
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
    static let addToRemindersMessage = "Your tasks now added to Reminders!"
    static let reminderNoTaskMessage = "You have no assigned task at the moment."
}

enum LabelStrings {
    static let getStarted = "Please enter your full name \n to get started."
    static let host = "Host"
    static let eventInfo = "Event Info"
    static let date = "Date"
    static let location = "Location"
    static let addToCalendar = "Add to Calendar"
    
    // RecipeVC
    static let noRecipeTitle = "No recipes selected"
    static let noRecipeMessage = "Go back and Add something!"
    
    // ManagementVC
    static let noTaskTitle = "Nothing's missing? \nIn need of a helping plan?"
    static let noTaskMessage = "Things help you manage and organise your event. Missing any ingredients but it's too late to buy them? Let your invitees help you with that."
    static let noTaskMessage2 = "Start by tapping"
    
    static let whatsThePlan = "Would you like to add an invitation message? \nMore information? Anything else?"
    static let nothingToDo = "There is nothing to do!"
    static let readyToSend = "Ready to send your invite?"
    static let noCustomRecipeTitle = "No recipe"
    static let noCustomRecipeMessage = "You can create your own recipe!"
    static let cookingTipsPlaceholder = "Anything else you want to mention?"
    static let update = "Update"
    static let selectNewDate = "Select a new date for your event:"
    static let readyToSend1 = "You're all set now! 💪 \nReady to send your invite?"
    static let readyToSend2 = "You're all set now! 🦾 \nReady to send your invite?"
    static let rescheduleTitle = "Need to reschedule?"
    static let rescheduleText = "No problem, simply choose another date! 😅👌"
    static let pastEventTitle = "Past Event"
    static let canceledEventTitle = "Canceled Event"
    static let pastEventDescription = "Looks like this event is in the past but don't fret, cooking is still better together! Create a new event and send an invite! 🤩👍"
    static let canceledEventDescription = "Looks like the host has canceled this event but don't fret, cooking is still better together! Create a new event and send an invite! 🤩👍"
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
    
}

enum Images {
    static let chatIcon = "chatIcon"
    static let inviteIcon = "inviteIcon"
    static let thingsIcon = "thingsIcon"
}
