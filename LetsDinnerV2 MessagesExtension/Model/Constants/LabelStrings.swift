//
//  LabelStrings.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 31/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

enum LabelStrings {
    static let next = NSLocalizedString("Next", comment: "Next")
    
    // InitialVC
    static let letsdinner = "Let's Dinner!"
    static let letsdinnerSubtitle = NSLocalizedString("Organize an event and cook together.", comment: "lets dinner subtitle")
    static let newEvent = NSLocalizedString("New Event", comment: "new event")
    
    // IdleVC
    static let continueButton = NSLocalizedString("Continue", comment: "continue")
    
    // RegistrationVC
    static let getStarted = NSLocalizedString("Please enter your full name \n to get started.", comment: "enter full name")
    static let save = NSLocalizedString("Save", comment: "save")
    static let profile = NSLocalizedString("Profile", comment: "profile")
    static let addImage = NSLocalizedString("Add image", comment: "add image")
    static let personalInfo = NSLocalizedString("PERSONAL INFORMATION", comment: "personal info")
    static let measurementSystem = NSLocalizedString("SYSTEM OF MEASUREMENT", comment: "system of measurement")
    static let enterFullName = NSLocalizedString("Please enter your full name", comment: "please enter full name")
    static let firstName = NSLocalizedString("First Name", comment: "first name")
    static let lastName = NSLocalizedString("Last Name", comment: "last name")
    static let address = NSLocalizedString("Address", comment: "address")
    static let metric = NSLocalizedString("Metric", comment: "metric")
    static let imperial = NSLocalizedString("Imperial", comment: "imperial")
    static let modifyImage = NSLocalizedString("Modify image", comment: "modify image")
    
    // NewEventVC
    static let host = NSLocalizedString("Host", comment: "host")
    static let date = NSLocalizedString("Date", comment: "date")
    static let location = NSLocalizedString("Location", comment: "location")
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
    static let deleteRecipeLabel = NSLocalizedString("To delete a recipes, swipe left.", comment: "delete instruction")
    static let rearrangeRecipeLabel = NSLocalizedString("To rearrange the order, tap and hold to move.", comment: "rearrange instruction")
    
    // CustomRecipeVC
    static let noCustomRecipeTitle = NSLocalizedString("No recipe", comment: "no recipe title")
    static let noCustomRecipeMessage = NSLocalizedString("You can create your own recipe!", comment: "no recipe message")
    
    // CreateRecipeVC
    static let cookingTipsPlaceholder = NSLocalizedString("Anything else you want to mention?", comment: "cooking tips placeholder")
    static let startCreateRecipeTitle = NSLocalizedString("Create your own custom recipes to cook your favourite meals!", comment: "create recipe title")
    static let startCreateRecipeMessage1 = NSLocalizedString("A great recipe provides you with all the information you need to cook it along the way.", comment: "create recipe message 1")
    static let startCreateRecipeMessage2 = NSLocalizedString("Start with an Image and a name. Then add ingredients, cooking steps or any other information such as tips to your recipe.", comment: "create recipe message 2")
    static let startCreateRecipeMessage3 = NSLocalizedString("Don't forget anything, to not make any mistakes. Having as much information as possible will get really nifty.", comment: "create recipe message 3")
    static let noTipsAndComments = NSLocalizedString("No Tips & Comments", comment: "no Tips And Comments")
    
    // ManagementVC
    static let noTaskTitle = NSLocalizedString("Nothing's missing? \nIn need of a helping hand?", comment: "no task title")
    static let noTaskMessage = NSLocalizedString("Things help you manage and organise your event. Missing any ingredients but it's too late to buy them? Let your invitees help you with that.", comment: "no task message")
    static let noTaskMessage2 = NSLocalizedString("Start by tapping", comment: "no task instructions")
    static let deleteTaskLabel = NSLocalizedString("To delete a Thing, swipe left.", comment: "delete instruction")
    static let assignTaskLabel = NSLocalizedString("To assign yourself to a Thing or to complete it, tap it or swipe right.", comment: "assign instruction")
    static let manageThings = NSLocalizedString("Manage Things", comment: "title")
    static let recipes = NSLocalizedString(" Recipes", comment: "recipes")
    static let addThing = NSLocalizedString("  Add Thing", comment: "add thing")
    static let misc = NSLocalizedString("Miscellaneous", comment: "miscellaneous")
    
    // DescriptionVC
    static let whatsThePlan = NSLocalizedString("What's the plan?", comment: "what's the plan")
    static let eventPlaceholder = NSLocalizedString("Would you like to add an invitation message? \nMore information? Anything else?", comment: "event description placeholder")
    static let nothingToDo = NSLocalizedString("There is nothing to do!", comment: "there is nothing to do")
    static let things = NSLocalizedString(" Things", comment: "things")
    static let addDescription = NSLocalizedString("Add Description", comment: "add description")
    static let maxCount = NSLocalizedString("No more than 400 characters please! 😁", comment: "character limit")
    
    // ReviewVC
    static let readyToSend1 = NSLocalizedString("You're all set now! 💪 \nReady to send your invite?", comment: "ready to send")
    static let readyToSend2 = NSLocalizedString("You're all set now! 🦾 \nReady to send your invite?", comment: "ready to send")
    static let update = NSLocalizedString("Update", comment: "update")
    static let send = NSLocalizedString("Send", comment: "send")
    static let edit = NSLocalizedString("Edit", comment: "edit")
    static let addToCalendar = NSLocalizedString("Add to Calendar", comment: "Add to calendar")
    
    // EventSummaryVC
    static let invitationText = NSLocalizedString("Hey you received an invite! 🤩 \nDo you want to accept it?", comment: "invite received")
    static let acceptedLabel = NSLocalizedString("You've accepted the invitation", comment: "invitation accepted")
    static let declinedLabel = NSLocalizedString("You've declined the invitation", comment: "invitation declined")
    static let allDoneLabel = NSLocalizedString("All done, greatjob! Everything has been taken care of. Let the party begins! 😎🥳", comment: "all tasks done")
    static let nothingToDoLabel = NSLocalizedString("Nope! Either, there is nothing to do or the host is handling everything 😬🙌", comment: "no tasks to do")
    static let eventInfo = NSLocalizedString("Event Info", comment: "event info")
    static let eventUnavailable = NSLocalizedString("We could not find this event, you may want to check your internet connection and try again. Events that are too old may not be available anymore.", comment: "event not found in firebase")
    
    // TasksListVC
    static let multipleUsers = NSLocalizedString("Other guests are selecting tasks now, an update may be coming soon! 🚀", comment: "multiple users checking")
    static let calendar = NSLocalizedString("Calendar", comment: "calendar")
    static let reminders = NSLocalizedString("Reminders", comment: "reminders")
    static let cookingManual = NSLocalizedString("Create Cooking Manual", comment: "create cooking manual")
    static let back = NSLocalizedString(" Back", comment: "back")
    static let updateServings = NSLocalizedString("Update servings? %d", comment: "update servings")
    
    // EventInfoVC
    static let eventInfoLabel = NSLocalizedString("You can sync the things assigned to you with Reminders and add the event to your Calendar.", comment: "sync description")
    
    
    // Reschedule
    static let rescheduleTitle = NSLocalizedString("Need to reschedule?", comment: "need to reschedule?")
    static let rescheduleText = NSLocalizedString("No problem, simply choose another date! 👌", comment: "no problem, simply choose another date")

    // Past Event
    static let pastEventTitle = NSLocalizedString("Past Event", comment: "past event title")
    static let pastEventDescription = NSLocalizedString("Looks like this event is in the past but don't fret, cooking is still better together! Create a new event and send an invite! 🤩👍", comment: "past event description")
    
    // Canceled Event
    static let canceledEventTitle = NSLocalizedString("Canceled Event", comment: "canceled event")
    static let canceledEventDescription = NSLocalizedString("Looks like the host has canceled this event but don't fret, cooking is still better together! Create a new event and send an invite! 🤩👍", comment: "canceled event description")
    
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
    
    
    // Message Bubble
    static let caption = NSLocalizedString("Tap to view this event", comment: "Message caption")
    static let task = NSLocalizedString("task", comment: "task")
    static let tasks = NSLocalizedString("tasks", comment: "tasks")
    static let updatedServingsSummary = NSLocalizedString("%@ updated the servings!", comment: "updated the servings")
    static let updatedTasksSummary = NSLocalizedString("%@ updated %d %@!", comment: "username updated numberOfTask task(s)!")
    static let updatedTasksAndServingsSummary = NSLocalizedString("%@ updated %d %@ and the servings!", comment: "username updated numberOfTask task(s) and the servings!")
    
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
    
    // ExpiredEventVC
    static let createNewEvent = NSLocalizedString("Create a new Event", comment: "create a new event")
    
    // RecipeDetails
    static let servingLabel = NSLocalizedString("For %@ people", comment: "servingLabel")
    static let servingDisplayLabel = NSLocalizedString("%@ servings", comment: "servingDisplayLabel")

    // RecipeBookVC + PDFCreator
    static let recipeBook = NSLocalizedString("Cooking Manual", comment: "Recipe book")
    static let recipe = NSLocalizedString("Recipe", comment: "recipe")
    static let tipsAndComments = NSLocalizedString("Tips & Comments", comment: "tips and comments")
    static let link = NSLocalizedString("Link: %@", comment: "Recipe link")
    static let ingredientTitle = NSLocalizedString("Ingredients for %d people \n\n", comment: "Ingredients for 2 people")
    static let instructions = NSLocalizedString("Instructions", comment: "instructions")
}
