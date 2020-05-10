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
    static let searchType = "searchType"
    
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
    static let next = NSLocalizedString("Next", comment: "Next")
    
    // StartVC
    static let getStarted = "Please enter your full name \n to get started."
    
    // NewEventVC
    static let host = NSLocalizedString("Host", comment: "host")
    static let date = NSLocalizedString("Date", comment: "date")
    static let location = NSLocalizedString("Location", comment: "location")
    static let addToCalendar = "Add to Calendar"
    static let addEventDetails = NSLocalizedString("Add Event Details", comment: "title")
    static let eventName = NSLocalizedString("Event name", comment: "event name")
    static let allFieldsRequired = NSLocalizedString("All fields are required 🤓", comment: "all fields required")
    static let breakfast = NSLocalizedString("Breakfast", comment: "breakfast")
    static let lunch = NSLocalizedString("Lunch", comment: "lunch")
    static let dinner = NSLocalizedString("Dinner", comment: "dinner")
    
    // RecipesVC
    static let noRecipeTitle = NSLocalizedString("No recipes selected", comment: "no recipes selected")
    static let noRecipeMessage = NSLocalizedString("Go back and Add something!", comment: "go back and add sthg")
    static let skip = NSLocalizedString("Skip", comment: "skip")
    static let chooseRecipes = NSLocalizedString("Choose Recipes", comment: "choose recipes")
    static let details = NSLocalizedString(" Details", comment: "details")
    static let discoverRecipes = NSLocalizedString("DISCOVER THESE RECIPES", comment: "discover")
    static let yourRecipes = NSLocalizedString("YOUR RECIPES", comment: "your recipes")
    static let searchApiRecipes = NSLocalizedString("Search 360K+ recipes", comment: "api search placeholder")
    static let searchMyRecipes = NSLocalizedString("Search my recipes", comment: "custom search placeholder")
    static let noResults = NSLocalizedString("No results! 😬", comment: "no results")
    
    
    // SelectedRecipe VC
    static let deleteRecipeLabel = "To delete a recipes, swipe left."
    static let rearrangeRecipeLabel = "To rearrange the order, tap and hold to move."
    
    // CustomRecipeVC
    static let noCustomRecipeTitle = "No recipe"
    static let noCustomRecipeMessage = "You can create your own recipe!"
    
    // CreateRecipeVC
    static let cookingTipsPlaceholder = "Anything else you want to mention?"
    static let startCreateRecipeTitle = "Create a custom recipe and cook your favourite meal!"
    static let startCreateRecipeMessage1 = "A greate recipe provides you with every information you need to cook it along the way. Start with an Image and a name."
    static let startCreateRecipeMessage2 = "Then add ingredients, cooking steps or any other information such as tips to your recipe."
    static let startCreateRecipeMessage3 = "Don't forget anything, to not make any mistakes. Having as much information as possible will get really nifty."
    static let startCreateRecipeMessage4 = "Start by tapping"
    

    // ManagementVC
    static let noTaskTitle = "Nothing's missing? \nIn need of a helping hand?"
    static let noTaskMessage = "Things help you manage and organise your event. Missing any ingredients but it's too late to buy them? Let your invitees help you with that."
    static let noTaskMessage2 = "Start by tapping"
    static let deleteTaskLabel = "To delete a Thing, swipe left."
    static let assignTaskLabel = "To assign yourself to a Thing or to complete it, tap it or swipe right."
    
    // DescriptionVC
    static let whatsThePlan = "Would you like to add an invitation message? \nMore information? Anything else?"
    static let nothingToDo = "There is nothing to do!"
    
    // ReviewVC
    static let readyToSend = "Ready to send your invite?"
    static let readyToSend1 = "You're all set now! 💪 \nReady to send your invite?"
    static let readyToSend2 = "You're all set now! 🦾 \nReady to send your invite?"
    static let update = "Update"
    
    // EventSummaryVC
    static let invitationText = "Hey you received an invite! 🤩 \nDo you want to accept it?"
    static let acceptedLabel = "You've accepted the invitation"
    static let declinedLabel = "You've declined the invitation"
    static let allDoneLabel = "All done, greatjob! Everything has been taken care of. Let the party begins! 😎🥳"
    static let nothingToDoLabel = "Nope! Either, there is nothing to do or the host is handling everything 😬🙌"
    static let eventInfo = "Event Info"
    
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
    static let neverLeaveDescription = NSLocalizedString("Let's Dinner! will not flood your chat, so you can keep on chatting about that new video 😻🐶", comment: "in WelcomeVC")
    static let letsGo = "Ok, Let's go!"
    
    // Message Bubble
    static let caption = NSLocalizedString("Tap to view this event", comment: "Message caption")
    
    // Premium Screen
    static let restore = NSLocalizedString("Restore purchases", comment: "Restore purchases")
    static let premiumAppName = "Let's Dinner "
    static let premiumPro = "Pro!"
    static let premiumDescription = NSLocalizedString("Let's Dinner! was created by six people from accross the world. Your Let's Dinner Pro! subscription will let you create events, enjoy neat features, and help to ensure future development! Have a look:", comment: "Premium description")
    static let premiumNoThanks = NSLocalizedString("No, thank you. Maybe later.", comment: "No thanks")
    static let premiumSubscribe = NSLocalizedString("Subscribe for 0.99€ / month", comment: "Subscribe for")
    
    //ThankYou Screen
    static let thankYou = NSLocalizedString("Thank you so much and\nwelcome to Let's Dinner Pro!", comment: "Thank you message")
    static let thankYouDescriptionPartOne = NSLocalizedString("Let’s Dinner! was created with a lot of love and care. It means the world to us that you purchased Let’s Dinner Pro! We hope that you’re happy with your new app and can put it to good use.", comment: "Thank you Description Part 1")
    static let thankYouDescriptionPartTwo = NSLocalizedString("With your one time purchase you help to keep our costs down and ensure future development.", comment: "Thank you Description Part 2")
    static let okLetsDinner = "Ok, Let's Dinner!"
}

enum Images {
    
    static let chevronLeft = UIImage(named: "chevronLeft")
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
    
    // ThankYou Screen
    static let heartIcon = "heartButtonOutlined"
}

enum DataKeys {
    static let recipePictures = "RecipePictures"
    static let profilePictures = "ProfilePictures"
}



