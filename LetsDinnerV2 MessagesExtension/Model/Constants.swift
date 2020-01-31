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
}

enum ApiKeys {
        static let appId =  "5dbeb10b"
        static let apiKey = "b92d6e0482b3e23150ef3060aec1fd31"
        static let apiKeySpoonacular = "123e94eacbbf40e497d48a0dd5b83189"
    // In case too many requests during testing
        static let backUpKey = "b07aca6301b44075ac9b4c9b09a2b3ac"
}

enum MessagesToDisplay {
    static let calendarAlert = "This event was successfully added to your calendar."
    static let acceptInviteAlert = "Please accept the invitation to manage the tasks."
    static let userHasDeclinedAlert = "You declined the invitation, you can not manage the tasks."
    static let acceptedInvitation = " accepted the invitation"
    static let declinedInvitation = " declined the invitation"
    static let eventExists = "This event is already in your calendar"
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
    static let noTaskTitle = "There is nothing to do for your event"
    static let noTaskMessage = "You can add things, they will appear here"
    static let whatsThePlan = "- Would you like to add an invitation message? \n- More information? Anything else?"
    static let nothingToDo = "There is nothing to do!"
    static let readyToSend = "Ready to send your invite?"
    static let noCustomRecipeTitle = "No recipe"
    static let noCustomRecipeMessage = "You can create your own recipe!"
    static let cookingTipsPlaceholder = "Any tips about this recipe?"
}
