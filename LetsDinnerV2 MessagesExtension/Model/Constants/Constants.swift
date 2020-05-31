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
    static let recipeCreationViewController = "RecipeCreationViewController"
    static let customRecipeDetailsViewController = "CustomRecipeDetailsViewController"
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
    static let taskCVCell = "TaskCVCell"
    static let taskCell = "TaskCell"
    static let userCVCell = "UserCVCell"
    static let taskManagementCell = "TaskManagementCell"
    static let recipeCVCell = "RecipeCVCell"
    static let sectionInputCell = "SectionInputCell"
    static let ingredientCell = "IngredientCell"
    static let createRecipeIngredientCell = "CreateRecipeIngredientCell"
    static let createRecipeCookingStepCell = "CreateRecipeCookingStepCell"
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
    static let searchType = "searchType"
    static let createCustomRecipeWelcomeVCVisited = "createCustomRecipeWelcomeVCVisited"
    
}

enum AlertStrings {
    // Add to Calendar Alert
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
    static let unsubmittedTasks = NSLocalizedString("Dismiss changes?", comment: "dismiss changes?")
    static let submitQuestion = NSLocalizedString("You made changes in this list. Would you like to update it?", comment: "you made changes")
    static let syncTitle = NSLocalizedString("Things synchronization", comment: "things synchronization")
    static let syncMessage = NSLocalizedString("Changes made, can end up unsaved. Whoever updates first, saves their changes.", comment: "sync message")
    static let update = NSLocalizedString("Update", comment: "update")
    static let goodToKnow = NSLocalizedString("Good to know!", comment: "good to know")
    
    // Decline Event Alert
    static let declineEventAlertTitle = "Do you want to decline?"
    static let declineEventAlertMessage = "By declining, you won't able to participate the event."
    
    
    
    static let cancel = NSLocalizedString("Cancel", comment: "cancel")
    static let add = NSLocalizedString("Add", comment: "add")
    static let addThing = "Add a thing"
    static let thingToAdd = "Thing to add"
    static let noNetwork = "No Network"
    static let decodingFailed = "Failed to load recipes"
    static let requestLimit = "Too many requests"
    static let tryAgain = "You can try again in a minute"
    static let nope = NSLocalizedString("Nope", comment: "nope")
    static let change = NSLocalizedString("Change", comment: "change")
    static let delete = NSLocalizedString("Delete", comment: "delete")
    static let myImage = NSLocalizedString("My image", comment: "my image")
    static let oops = NSLocalizedString("Oops", comment: "string")
    static let errorFetchImage = NSLocalizedString("Your image could not be found", comment: "your image could not be found")
    static let confirm = NSLocalizedString("Confirm", comment: "confirm")
    static let decline = NSLocalizedString("Decline", comment: "decline")

}



enum Images {
    
    static let chevronLeft = UIImage(named: "chevronLeft")
    static let settings = UIImage(named: "settingsButtonOutlinedWhite")
    static let logo = UIImage(named: "appIconWhite")
    // Welcome Screen
    static let chatIcon = UIImage(named: "chatIcon")!
    static let inviteIcon = UIImage(named: "inviteIcon")!
    static let thingsIcon = UIImage(named: "thingsIcon")!
    
    // MessageBubble
    static let premiumBackground = "iMessageBackground"
    static let premiumBackgroundOld = "iMessageBackgroundOld"
    static let standardBackground = "bubbleBackground"
    static let chevronDisclosure = "chevronDisclosure"
    static let statusPending = "statusPending"
    static let statusAccepted = "statusAccepted"
    static let statusDeclined = "statusDeclined"
    
    // RegistrationVC
    static let profilePlaceholder = UIImage(named: "profilePlaceholderBig")!
    static let checkmark = UIImage(named: "checkmark")!
    
    // NewEventVC
    static let settingsButtonOutlined = UIImage(named: "settingsButtonOutlined")!
    static let titleIcon = UIImage(named: "titleIcon")!
    static let locationIcon = UIImage(named: "locationIcon")!
    static let hostIcon = UIImage(named: "hostIcon")!
    static let dateIcon = UIImage(named: "dateIcon")!
    
    // RecipesVC
    static let addButtonOutlined = UIImage(named: "addButtonOutlined")!
    static let recipeBookButtonOutlined = UIImage(named: "recipeBookButtonOutlined")!
    static let listButtonOutlined = UIImage(named: "listButtonOutlined")!
    static let discoverButtonOutlined = UIImage(named: "discoverButtonOutlined")!
    
    // CustomRecipeDetailsVC
    static let imagePlaceholderBig = UIImage(named: "imagePlaceholderBig")
    static let recipeBookIcon = UIImage(named: "recipeBookIcon")
    
    // TasksListVC
    static let sortIcon = UIImage(named: "sortButtonOutlined")!
    
    // ThankYou Screen
    static let heartIcon = "heartButtonOutlined"
    
    //TaskStatusButton
    static let checkboxOutlined = UIImage(named: "checkboxOutlined")!
    static let assignedImage = UIImage(named: "checkboxAssignedOutlined")!
    static let completedImage = UIImage(named: "checkboxAssignedCompleted")!
    static let completedByOtherImage = UIImage(named: "checkBoxCompleted")!
}

enum ButtonTitle {
    static let letsGo = NSLocalizedString("Ok, Let's go!", comment: "ok lets go")
    static let back = NSLocalizedString("Back", comment: "back")
}

enum DataKeys {
    static let events = "Events"
    static let recipePictures = "RecipePictures"
    static let profilePictures = "ProfilePictures"
    static let eventName = "dinnerName"
    static let hostName = "hostName"
    static let dateTimestamp = "dateTimestamp"
    static let eventLocation = "dinnerLocation"
    static let eventDescription = "eventDescription"
    static let hostID = "hostID"
    static let sourceUrl = "sourceUrl"
    static let id = "id"
    static let recipes = "recipes"
    static let customRecipes = "customRecipes"
    static let servings = "servings"
    static let ingredients = "ingredients"
    static let downloadUrl = "downloadUrl"
    static let comments = "comments"
    static let cookingSteps = "cookingSteps"
    static let onlineUsers = "onlineUsers"
    static let isCancelled = "isCancelled"
    static let customOrder = "customOrder"
    static let tasks = "tasks"
    static let title = "title"
    static let ownerName = "ownerName"
    static let ownerUid = "ownerUid"
    static let state = "state"
    static let isCustom = "isCustom"
    static let parentRecipe = "parentRecipe"
    static let metricUnit = "metricUnit"
    static let metricAmount = "metricAmount"
    static let fullName = "fullName"
    static let hasAccepted = "hasAccepted"
    static let profilePicUrl = "profilePicUrl"
    static let participants = "participants"
}



