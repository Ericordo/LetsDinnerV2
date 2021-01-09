//
//  File.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 1/6/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

enum AlertStrings {
    // Add to Calendar Alert
    static let calendarAlert = NSLocalizedString("This event was successfully added to your calendar.", comment: "calendar alert success message")
    static let addToCalendarAlertTitle = NSLocalizedString("Add to calendar?", comment: "calendar alert title")
    static let addToCalendarAlertMessage = NSLocalizedString("You can add this event to your calendar, to make sure you wont be running late!", comment: "calendar alert description message")
    static let calendarDenied = NSLocalizedString("The app is not permitted to access your calendar, make sure to grant permission in the settings and try again.", comment: "access to calendar denied")
    static let calendarAccess = NSLocalizedString("Calendar access", comment: "calendar access")
    static let settings = NSLocalizedString("Settings", comment: "settings")
    static let addToCalendarError = NSLocalizedString("We could not add the Event to your calendar", comment: "add to calendar error")

    // Accept Or Decline Alert
    static let acceptInviteAlert = NSLocalizedString("Please accept the invitation to manage the tasks.", comment: "alert when someone wants to see the task before accepting")
    static let userHasDeclinedAlert = NSLocalizedString("You declined the invitation, you are not able to manage the tasks.", comment: "alert when someone wants to update tasks despite declined")
    static let acceptedInvitation = NSLocalizedString("%@ accepted the invitation", comment: "name accepted")
    static let declinedInvitation = NSLocalizedString("%@ declined the invitation", comment: "name declined")
    
    // Cancel Event Alert
    static let cancelEventAlertTitle = NSLocalizedString("Cancel Event?", comment: "cancel event alert title")
    static let cancelEventAlertMessage = NSLocalizedString("You are about to cancel this event, this action will delete the invitation you created. Are you sure you want to cancel the event?", comment: "cancel event alert description")
    
    // Add Reminder Alert
    static let success = NSLocalizedString("Success", comment: "success")
    static let addToRemindersMessage = NSLocalizedString("Your tasks were added to your reminders!", comment: "tasks added to remiunders")
    static let remindersNoTaskTitle = NSLocalizedString("No task!", comment: "no task")
    static let remindersNoTaskMessage = NSLocalizedString("You have not selected any task yet.", comment: "no tasks selected yet")
    static let remindersAccess = NSLocalizedString("Reminders access", comment: "reminders access")
    static let remindersDenied = NSLocalizedString("The app is not permitted to access your reminders, make sure to grant permission in the settings and try again.", comment: "access to reminders denied")
    static let eventExisted = NSLocalizedString("This event is already in your calendar.", comment: "event already in calendar ")
    static let completed = NSLocalizedString("Completed", comment: "completed")
    static let assignedToMyself = NSLocalizedString("Assigned to myself", comment: "assigned to myself")
    static let noAssignment = NSLocalizedString("No assignment", comment: "no assignment")
    static let yes = NSLocalizedString("Yes", comment: "yes")
    static let no = NSLocalizedString("No", comment: "no")
    static let noNeed = NSLocalizedString("No need!", comment: "no need to add event, already there")
    static let addToRemindersError = NSLocalizedString("We could not add the tasks to your reminders", comment: "add to reminders error")
    
    // TaskListVC Alert
    static let unsubmittedTasks = NSLocalizedString("Pending changes", comment: "pending changes")
    static let submitQuestion = NSLocalizedString("You made changes in this list. Would you like to update it?", comment: "you made changes")
    static let updateTitle = NSLocalizedString("Update required", comment: "update required")
    static let updateDescription = NSLocalizedString("Some tasks have been updated by other participants, let's refresh!", comment: "update instructions")
    static let applyChanges = NSLocalizedString("Some of the tasks you wanted are still free, would you like to take them?", comment: "reapply previous changes after external update")
    static let taskUpdateFail = NSLocalizedString("We could not update your tasks.", comment: "task update error")
    
    // Decline Event Alert
    static let declineEventAlertTitle = NSLocalizedString("Decline?", comment: "decline event alert title")
    static let declineEventAlertMessage = NSLocalizedString("The others will miss you!", comment: "decline event alert description")
    static let add = NSLocalizedString("Add", comment: "add")
    static let addThing = NSLocalizedString("Add a thing", comment: "add a thing")
    static let thingToAdd = NSLocalizedString("Thing to add", comment: "thing to add")
    static let noNetwork = NSLocalizedString("It seems that the network is not available.", comment: "no network")
    static let decodingFailed = NSLocalizedString("We could not load the recipes.", comment: "failed to load recipes")
    static let requestLimit = NSLocalizedString("You did a lot of searches for now! Please try again later.", comment: "too many requests")
    static let myImage = NSLocalizedString("My image", comment: "my image")
    static let oops = NSLocalizedString("Oops!", comment: "string")
    static let errorFetchImage = NSLocalizedString("Your image could not be found", comment: "your image could not be found")
    static let statusUpdateError = NSLocalizedString("We could not save your reply.", comment: "status update error")
    
    // Create Recipe VC
    static let retrieveImageErrorMessage = NSLocalizedString("We could not retrieve the picture.", comment: "retrieve image error message")
    static let recipeNameMissing = NSLocalizedString("Please give a name to your recipe. 😄", comment: "recipe name missing error")
    static let recipeSaveCloudError = NSLocalizedString("We could not save your recipe.", comment: "recipe save error")
    static let recipeUpdateCloudError = NSLocalizedString("We could not update your recipe.", comment: "recipe update error")
    static let recipeDeleteCloudError = NSLocalizedString("We could not delete your recipe.", comment: "recipe delete error")
    static let recipeFetchCloudError = NSLocalizedString("We could not retrieve your recipes.", comment: "recipe fetch error")
    static let notSignedInCloudError = NSLocalizedString("You need to be signed into iCloud to do this.", comment: "not signed into iCloud error")
    static let recipeSaveRealmError = NSLocalizedString("We could not save the recipe in your device, but it was saved in iCloud.", comment: "save recipe locally error")
    static let transferToRealmError = NSLocalizedString("We could not back-up your recipes to your device.", comment: "recipes back up error")
    static let recipeUpdateRealmError = NSLocalizedString("We could not update the recipe in your device, but it was updated in iCloud.", comment: "recipe update realm error")
    static let recipeDeleteRealmError = NSLocalizedString("We could not delete the recipe in your device, but it was deleted in iCloud", comment: "recipe delete realm error")
    static let ongoingRecipeTitle = NSLocalizedString("Recipe in Progress! 👷🏻‍♂️", comment: "recipe in progress alert title")
    static let ongoingRecipeDescription = NSLocalizedString("It seems that you left the app while creating a recipe. Would you like to restore your progress?", comment: "recipe in progress alert description")
    static let publicRecipeUploadFail = NSLocalizedString("", comment: "")
    static let publicRecipeUpdateFail = NSLocalizedString("", comment: "")

    // ReviewVC
    static let eventUploadFail = NSLocalizedString("We could not save your Event, please try again.", comment: "could not upload event")
    
    // EventSummaryVC
    static let eventFetchingFail = NSLocalizedString("We could not retrieve the information for this event.", comment: "could not fetch event")
    static let changedMind = NSLocalizedString("Changed your mind?", comment: "changed your mind")
    static let updateDeclinedStatus = NSLocalizedString("Would you like to accept this invitation?", comment: "accept this invitation")
    static let updateAcceptedStatus = NSLocalizedString("Would you like to decline this invitation?", comment: "decline this invitation")
    static let rescheduleFail = NSLocalizedString("We could not change the date of your event.", comment: "could not reschedule event")
    
    // RegistrationVC
    static let profilePicUploadError = NSLocalizedString("We could not save your profile picture", comment: "error saving provfile pic")
    // Action Sheet
    static let doneActionSheetMessage = NSLocalizedString("Save or Discard your changes?", comment: "save or discard")
    static let saveImageErrorMessage = NSLocalizedString("Image cannot be saved", comment: "save image error message")
    static let changeImageActionSheetMessage = NSLocalizedString("Change or Delete your image?", comment: "change image")
    static let editRecipeActionSheetMessage = NSLocalizedString("Do you want to Edit or Delete %@ ?", comment: "edit recipe")
    static let genericError = NSLocalizedString("Sorry, something went wrong!", comment: "generic error message")
    
    // MARK: Authentication
    static let userNotLoggedIn = NSLocalizedString("We could not connect you to the database, this may be due to a network issue. Please check and try again!", comment: "not logged in firebase")
    static let loggedInSuccess = NSLocalizedString("You are now connected!", comment: "anonymous reauth successful")
    
    // MARK: Premium Subscription
    static let noProductIDsFound = NSLocalizedString("Let's Dinner Pro! is not available at the moment, please try again later.", comment: "no product id found")
    static let noProductsFound = NSLocalizedString("Let's Dinner Pro! is not available at the moment, please try again later.", comment: "no product found")
    static let paymentWasCancelled = NSLocalizedString("The purchase has been cancelled.", comment: "purchase cancelled")
    static let productRequestFailed = NSLocalizedString("Let's Dinner Pro! is not available at the moment, please try again later.", comment: "product request failed")
    static let paymentNotAvailable = NSLocalizedString("We can not proceed with your purchase, please try again later.", comment: "payment not available")
    static let purchaseFailed = NSLocalizedString("We can not proceed with your purchase, please try again later.", comment: "purchase failed")
    static let secretNotFetched = NSLocalizedString("Let's Dinner Pro! is not available at the moment, please try again later.", comment: "secret not fetched from firebase")
    static let receiptVerificationFail = NSLocalizedString("We could not verify your Let's Dinner Pro! subscription, please try again later.", comment: "receipt verification fail")
    static let restoreFailed = NSLocalizedString("We could not restore your purchase, please try again later.", comment: "fail to restore")
    static let nothingToRestore = NSLocalizedString("You do not have an ongoing subscription to Let's Dinner Pro!, so there is nothing to restore!", comment: "nothing to restore")
    
    
    // MARK: Action
    static let okAction = NSLocalizedString("OK", comment: "ok")
    static let editAction = NSLocalizedString("Edit", comment: "edit")
    static let confirm = NSLocalizedString("Confirm", comment: "confirm")
    static let decline = NSLocalizedString("Decline", comment: "decline")
    static let cancel = NSLocalizedString("Cancel", comment: "cancel")
    static let delete = NSLocalizedString("Delete", comment: "delete")
    static let update = NSLocalizedString("Update", comment: "update")
    static let save = NSLocalizedString("Save", comment: "save")
    static let discard = NSLocalizedString("Discard", comment: "discard")
    static let change = NSLocalizedString("Change", comment: "change")
    static let nope = NSLocalizedString("Nope", comment: "nope")
    static let connect = NSLocalizedString("Connect", comment: "connect")
    static let subscribe = NSLocalizedString("Subscribe", comment: "subscribe")
}
