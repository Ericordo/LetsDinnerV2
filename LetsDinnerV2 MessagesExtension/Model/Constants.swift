//
//  Constants.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 02/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard

enum Colors {
    static let gradientPink = UIColor(red:0.85, green:0.20, blue:0.42, alpha:1.0)
    static let gradientRed = UIColor(red:0.88, green:0.21, blue:0.21, alpha:1.0)
    static let customPink = UIColor(red:0.84, green:0.10, blue:0.25, alpha:1.0)
    static let customGray = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
    static let hasAccepted = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
    static let hasDeclined = UIColor(red:0.82, green:0.01, blue:0.11, alpha:1.0)
    static let paleGray = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
    static let dullGray = UIColor(red: 138/255, green: 138/255, blue: 142/255, alpha: 1.0)
    static let newGradientPink = UIColor(red: 255/255, green: 111/255, blue: 133/255, alpha: 1.0)
    static let newGradientRed = UIColor(red: 255/255, green: 73/255, blue: 72/255, alpha: 1.0)
    static let customBlue = UIColor(displayP3Red: 0/255, green: 165/255, blue: 255/255, alpha: 1.0)
}

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
}

enum ApiKeys {
        static let appId =  "5dbeb10b"
        static let apiKey = "b92d6e0482b3e23150ef3060aec1fd31"
        static let apiKeySpoonacular = "123e94eacbbf40e497d48a0dd5b83189"
}

enum MessagesToDisplay {
    static let calendarAlert = "This event was successfully added to your calendar."
    static let acceptInviteAlert = "Please accept the invitation to manage the tasks."
    static let userHasDeclinedAlert = "You declined the invitation, you can not manage the tasks."
    static let acceptedInvitation = " accepted the invitation"
    static let declinedInvitation = " declined the invitation"
    static let eventExists = "This event is already in your calendar"
    static let completed = "Completed"
    static let assignedToYourself = "Assigned to yourself"
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
    static let whatsThePlan = "So, what's the plan?"
    static let nothingToDo = "There is nothing to do!"
    static let readyToSend = "Ready to send your invite?"
    static let noCustomRecipeTitle = "No recipe"
    static let noCustomRecipeMessage = "You can create one!"
}
