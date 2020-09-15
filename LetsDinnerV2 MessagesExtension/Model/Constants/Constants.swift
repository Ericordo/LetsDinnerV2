//
//  Constants.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 02/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard

enum CellNibs {
    static let recipeCell = "RecipeCell"
    static let answerCell = "AnswerCell"
    static let descriptionCell = "DescriptionCell"
    static let taskSummaryCell = "TaskSummaryCell"
    static let taskCVCell = "TaskCVCell"
    static let taskManagementCell = "TaskManagementCell"
    static let cancelCell = "CancelCell"
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
    static let addEventCalendar = "addEventCalendar"
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
    static let emptyPlate = UIImage(named: "emptyPlate")!
    static let mealPlaceholder = UIImage(named: "mealPlaceholderImage")
    
    // SelectedRecipesVC
    static let deleteBin = UIImage(named: "deleteBin")!
    
    // RecipeCreationVC
    static let editButton = UIImage(named: "editButton")
    static let addButton = UIImage(named: "addButton")
    static let imagePlaceholderBig = UIImage(named: "imagePlaceholderBig")
    static let recipeBookIcon = UIImage(named: "recipeBookIcon")
    
    // ManagementVC
    static let swipeActionAssign = UIImage(named: "swipeActionAssign")
    static let swipeActionComplete = UIImage(named: "swipeActionComplete")
    
    // AddThingView
    static let addTask = UIImage(named: "sendFill")
    
    // TasksListVC
    static let sortIcon = UIImage(named: "sortButtonOutlined")!
    
    // ThankYou Screen
    static let heartIcon = "heartButtonOutlined"
    
    // TaskStatusButton
    static let checkboxOutlined = UIImage(named: "checkboxOutlined")!
    static let assignedImage = UIImage(named: "checkboxAssignedOutlined")!
    static let completedImage = UIImage(named: "checkboxAssignedCompleted")!
    static let completedByOtherImage = UIImage(named: "checkBoxCompleted")!
    
    // PDFCreator
    static let pdfLogo = UIImage(named: "pdfLogo")!
    
    static let warning = UIImage(named: "warning")!
}

enum ButtonTitle {
    static let letsGo = NSLocalizedString("Ok, Let's go!", comment: "ok lets go")
    static let back = NSLocalizedString("Back", comment: "back")
    static let editImage = NSLocalizedString("Edit Image", comment: "edit image")
    static let addImage = NSLocalizedString("Add Image", comment: "add image")
    static let edit = NSLocalizedString("Edit", comment: "edit")
    static let done = NSLocalizedString("Done", comment: "done")
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
    static let imageUrl = "imageUrl"
    static let amount = "amount"
    static let unit = "unit"
}



