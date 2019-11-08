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
}

enum VCNibs {
    static let initialViewController = "InitialViewController"
    static let registrationViewController = "RegistrationViewController"
    static let newEventViewController = "NewEventViewController"
    static let recipesViewController = "RecipesViewController"
    static let recipeDetailsViewController = "RecipeDetailsViewController"
    static let eventDescriptionViewController = "EventDescriptionViewController"
    static let eventSummaryViewController = "EventSummaryViewController"
    static let tasksListViewController = "TasksListViewController"
}

enum CellNibs {
    static let recipeCell = "RecipeCell"
    static let answerCell = "AnswerCell"
    static let infoCell = "InfoCell"
    static let descriptionCell = "DescriptionCell"
    static let taskSummaryCell = "TaskSummaryCell"
    static let userCell = "UserCell"
    static let calendarCell = "CalendarCell"
    static let taskCVCell = "TaskCVCell"
    static let taskCell = "TaskCell"
    static let userCVCell = "UserCVCell"
}

enum ApiKeys {
        static let appId =  "5dbeb10b"
        static let apiKey = "b92d6e0482b3e23150ef3060aec1fd31"
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
    static let yes = "Yes"
    static let no = "No"
    static let unsubmittedTasks = "You have unsubmitted tasks."
    static let submitQuestion = "Do you want to submit them?"
    static let descriptionPrompt = "Please enter a description for your dinner."
}

enum LabelStrings {
    static let getStarted = "Please enter your full name \n to get started."
    static let host = "Host"
    static let date = "Date"
    static let location = "Location"
    static let addToCalendar = "Add to Calendar"
}
