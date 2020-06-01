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
    
    // Create Recipe VC
    // Action Sheet
    static let doneActionSheetMessage = NSLocalizedString("Save or Discard your changes?", comment: "save or discard")
    static let edit = NSLocalizedString("Edit", comment: "edit")
    
    static let errorTitle = NSLocalizedString("Error", comment: "error")
    static let saveImageErrorMessage = NSLocalizedString(" Image cannot be saved", comment: "save Image Error Message")
    static let okAction = NSLocalizedString("OK", comment: "ok")
    


}
