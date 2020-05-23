//
//  Event.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation
import Messages
import iMessageDataKit
import FirebaseDatabase
import RealmSwift

class Event {
    
    static let shared = Event()
    init () {}
    
    // Message Info
    var currentSession: MSSession?
    var currentUser: User?
    var currentConversationTaskStates = [Task]()
    var firebaseEventUid = ""
    var summary = ""
    
    // Event Details
    var dinnerName = ""
    var hostName = ""
    var dateTimestamp = Double()
    var dinnerLocation = ""
    var dinnerDate : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let date = Date(timeIntervalSince1970: dateTimestamp)
        let dateString = dateTimestamp == 0 ? "" : dateFormatter.string(from: date)
        return dateString
    }
    
    var eventIsExpired: Bool {
        let currentDateTimestamp = Date().timeIntervalSince1970
        return dateTimestamp < currentDateTimestamp
    }
    
    var eventDescription = String()
    var selectedRecipes = [Recipe]()
//    var selectedCustomRecipes = [CustomRecipe]()
    var selectedCustomRecipes = [LDRecipe]()
//    var recipeTitles: String {
//          let titles = selectedRecipes.map { $0.title! }
//          return titles.joined(separator:", ")
//    }
    
    // Helpful variable
    var hostIsRegistered = false
    var statusNeedUpdate = false
    var tasksNeedUpdate = false
    var servingsNeedUpdate = false
    
    var servings = 2
    var currentConversationServings = 2
    var hostIdentifier = ""

    var participants = [User]()
    var tasks = [Task]()
    
    var isAllTasksCompleted = false
    var isCancelled = false
    var isSyncAlertShownInTaskListVC = false
    
    var localEventId = ""
    
    // MARK: - Functions
    
    func resetEvent() {
        dinnerName.removeAll()
        hostName.removeAll()
        dinnerLocation.removeAll()
        selectedRecipes.removeAll()
        selectedCustomRecipes.removeAll()
        eventDescription.removeAll()
        dateTimestamp = 0.0
        tasks.removeAll()
        firebaseEventUid.removeAll()
        currentConversationTaskStates.removeAll()
        currentSession = nil
        hostIdentifier.removeAll()
        participants.removeAll()
        hostIsRegistered = false
        statusNeedUpdate = false
        tasksNeedUpdate = false
        servings = 2
        currentConversationServings = 2
        servingsNeedUpdate = false
        isCancelled = false
        isSyncAlertShownInTaskListVC = false
    }
    
    func prepareMessage(session: MSSession, eventCreation: Bool, action: SendAction) -> MSMessage {
        let bubbleManager = BubbleManager()
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "bubbleBackground")
        layout.imageTitle = dinnerName
        layout.imageSubtitle = dinnerDate
        layout.caption = "Tap to view Dinner! "
        let message: MSMessage = MSMessage(session: currentSession ?? MSSession())
        message.layout = layout
//        message.layout = bubbleManager.prepareMessageBubble()
        message.summaryText = summary
        message.md.set(value: dinnerName, forKey: "dinnerName")
        message.md.set(value: hostName, forKey: "hostName")
        message.md.set(value: dinnerLocation, forKey: "dinnerLocation")
        message.md.set(value: eventDescription, forKey: "eventDescription")
        message.md.set(value: dateTimestamp, forKey: "dateTimestamp")
        
        if eventCreation {
            if let hostID = currentUser?.identifier {
                message.md.set(value: hostID, forKey: "hostID")
            }
        } else {
            message.md.set(value: hostIdentifier, forKey: "hostID")
        }
        if eventCreation {
            localEventId = UUID().uuidString
            let firebaseChildUid = uploadEventToFirebase()
            message.md.set(value: firebaseChildUid, forKey: "firebaseEventUid")
        } else {
            message.md.set(value: firebaseEventUid, forKey: "firebaseEventUid")
        }
        bubbleManager.storeBubbleInformation(for: message, for: action)
         return message
    }
    
    func parseMessage(message: MSMessage) {
        if let dinnerName = message.md.string(forKey: "dinnerName") {
            self.dinnerName = dinnerName
        }
        if let hostName = message.md.string(forKey: "hostName") {
            self.hostName = hostName
        }
        if let dinnerLocation = message.md.string(forKey: "dinnerLocation") {
            self.dinnerLocation = dinnerLocation
        }
        if let eventDescription = message.md.string(forKey: "eventDescription") {
            self.eventDescription = eventDescription
        }
        if let dateTimestamp = message.md.double(forKey: "dateTimestamp") {
            self.dateTimestamp = dateTimestamp
        }
        if let firebaseEventUid = message.md.string(forKey: "firebaseEventUid") {
            self.firebaseEventUid = firebaseEventUid
        }
        if let hostIdentifier = message.md.string(forKey: "hostID") {
            self.hostIdentifier = hostIdentifier
        }
        observeEvent()
    }
    
    // MARK: FireBase Data
    func uploadEventToFirebase() -> String {
        guard let userID = currentUser?.identifier else { return "error" }
        let reference = Database.database().reference()
//          let ingredients = selectedRecipes.map { $0.ingredientList }
          
        let childUid = reference.child(userID).child("Events").childByAutoId()
        
        let parameters: [String : Any] = ["dinnerName" : dinnerName,
                                          "hostName" : hostName,
                                          "dateTimestamp" : dateTimestamp,
                                          "dinnerLocation" : dinnerLocation,
                                          "eventDescription" : eventDescription,
                                          "hostID" : userID]
        childUid.setValue(parameters)
          
        if !selectedRecipes.isEmpty {
              selectedRecipes.forEach { recipe in
                  let recipeChild = childUid.child("recipes").childByAutoId()
                
                  let parameters : [String : Any] = ["title" : recipe.title ?? "",
                                                     "sourceUrl" : recipe.sourceUrl ?? "",
                                                     "id" : recipe.id ?? 0,
                ]
                  recipeChild.setValue(parameters)
              }
          }
        
        if !selectedCustomRecipes.isEmpty {
            selectedCustomRecipes.forEach { customRecipe in
                var ingredients = [String : String]()
                customRecipe.ingredients.forEach { ingredient in
                    if let amount = ingredient.amount {
                         ingredients[ingredient.name] = ", \(amount) \(ingredient.unit ?? "")"
                    } else {
                        ingredients[ingredient.name] = ""
                    }
                }
                let customRecipeChild = childUid.child("customRecipes").childByAutoId()
                var parameters : [String : Any] = ["title" : customRecipe.title,
                                                   "ingredients" : ingredients,
                                                   "id" : customRecipe.id,
                                                   "servings" : customRecipe.servings,

                ]

                if let downloadUrl = customRecipe.downloadUrl {
                    parameters["downloadUrl"] = downloadUrl
                }
                var cookingSteps = [String]()
                customRecipe.cookingSteps.forEach { cookingStep in
                    cookingSteps.append(cookingStep)
                }
                if !cookingSteps.isEmpty {
                    parameters["cookingSteps"] = cookingSteps
                }
                if let comments = customRecipe.comments {
                    parameters["comments"] = comments
                }
                customRecipeChild.setValue(parameters)
                
            }
        }
        
        // Custom Order
        if !CustomOrderHelper.shared.customOrder.isEmpty {
            let customOrderChild = childUid.child("customOrder")
            CustomOrderHelper.shared.convertedCustomOrderForFirebaseStorage = CustomOrderHelper.shared.convertingTupleToArray(from: CustomOrderHelper.shared.customOrder)
            customOrderChild.setValue(CustomOrderHelper.shared.convertedCustomOrderForFirebaseStorage)
        }
        
            
        if !tasks.isEmpty {
            tasks.forEach { task in
                let taskChild = childUid.child("tasks").childByAutoId()
                var parameters : [String : Any] = ["title" : task.taskName,
                                                   "ownerName" : task.assignedPersonName,
                                                   "ownerUid" : task.assignedPersonUid ?? "nil",
                                                   "state": task.taskState.rawValue,
                                                   "isCustom" : task.isCustom,
                                                   "parentRecipe" : task.parentRecipe]
                if let amount = task.metricAmount {
                    parameters["metricAmount"] = amount
                }
                if let unit = task.metricUnit {
                    parameters["metricUnit"] = unit
                }
                taskChild.setValue(parameters)
            }
        }
 /// Commented out on 20.02.2020 because Host was pending even though he is the host... Means the currentUser had a pending status
//        let participantsParameters : [String : Any] = ["fullName" :                                                         defaults.username,
//                                                       "hasAccepted" : currentUser?.hasAccepted.rawValue ?? "",
//                                                       "profilePicUrl" : defaults.profilePicUrl]
        let participantsParameters : [String : Any] = ["fullName" :                                                         defaults.username,
                                                       "hasAccepted" : Invitation.accepted.rawValue,
                                                         "profilePicUrl" : defaults.profilePicUrl]
       
//        currentUser?.hasAccepted = .accepted
        childUid.child("participants").child(userID).setValue(participantsParameters)
        
        let onlineUsersChild = childUid.child("onlineUsers")
        onlineUsersChild.setValue(0)
        let isCancelledChild = childUid.child("isCancelled")
        isCancelledChild.setValue(isCancelled)
        let servingsChild = childUid.child("servings")
        servingsChild.setValue(servings)
        
//        let onlineParticipantsParameters : [String : Int] = ["onlineUsers" : 0]
//        childUid.setValue(onlineParticipantsParameters)
        
        if let key = childUid.key {
            self.firebaseEventUid = key
            return key
        } else {
            return "error"
        }
        
      }
    
    func observeEvent() {
        // Run Two times when click on the event in message bubble
        
        Database.database().reference().child(hostIdentifier).child("Events").child(firebaseEventUid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String : Any] else { return }
            guard let hostID = value["hostID"] as? String else { return }
            self.hostIdentifier = hostID
            
            if let isCancelled = value["isCancelled"] as? Bool {
                self.isCancelled = isCancelled
            }
            if let servings = value["servings"] as? Int {
                self.servings = servings
                self.currentConversationServings = servings
            }
            
            var users = [User]()
            guard let participants = value["participants"] as? [String : Any] else { return }
            
            participants.forEach { key, value in
                guard let dict = value as? [String : Any] else { return }
                guard let fullName = dict["fullName"] as? String else { return }
                guard let hasAccepted = dict["hasAccepted"] as? String else { return }
                guard let profilePicUrl = dict["profilePicUrl"] as? String else { return }
                
                let user = User(identifier: key,
                                fullName: fullName,
                                hasAccepted: Invitation(rawValue: hasAccepted)!)
                // New line
                user.profilePicUrl = profilePicUrl
                users.append(user)
            }
            self.participants = users
            
            //                The line below fixes the bug of tasks duplicated when tapping on back button from taskList without submitting changes
            self.currentConversationTaskStates.removeAll()
            var tasks = [Task]()
            //                Changed "ingredients" with "tasks" in line below
            if let currentTasks = value["tasks"] as? [String : Any] {
                currentTasks.forEach { (key, value) in
                    guard let dict = value as? [String : Any] else { return }
                    guard let title = dict["title"] as? String else { return }
                    guard let ownerName = dict["ownerName"] as? String else { return }
                    guard let ownerUid = dict["ownerUid"] as? String else { return }
                    guard let state = dict["state"] as? Int else { return }
                    guard let isCustom = dict["isCustom"] as? Bool else { return }
                    guard let parentRecipe = dict["parentRecipe"] as? String else { return }
                    
                    let task = Task(taskName: title, assignedPersonUid: ownerUid, taskState: state, taskUid: key, assignedPersonName: ownerName, isCustom: isCustom, parentRecipe: parentRecipe)
                    if let amount = dict["metricAmount"] as? Double {
                        task.metricAmount = amount
                    }
                    if let unit = dict["metricUnit"] as? String {
                        task.metricUnit = unit
                    }
                    tasks.append(task)
                    
                    let newTask = Task(taskName: title, assignedPersonUid: ownerUid, taskState: state, taskUid: key, assignedPersonName: ownerName, isCustom: isCustom, parentRecipe: parentRecipe)
                    if let amount = dict["metricAmount"] as? Double {
                        newTask.metricAmount = amount
                    }
                    if let unit = dict["metricUnit"] as? String {
                        newTask.metricUnit = unit
                    }
                    self.currentConversationTaskStates.append(newTask)
                    //                I don't understand why with the line below, the number of updated tasks is always 0, but it works fine with the 2 lines above. Debugger seems to always crash with the 2 lines above instead of line below
                    //                self.currentConversationTaskStates.append(task)
                }
            }
            self.tasks = tasks
            
            // CustomOrder
            if let customOrder = value["customOrder"] as? [String] {
                CustomOrderHelper.shared.customOrder = CustomOrderHelper.shared.convertingArrayToTuple(from: customOrder)
            }
            
            var recipes = [Recipe]()
            
            if let selectedRecipes = value["recipes"] as? [String : Any] {
                selectedRecipes.forEach { (key, value) in
                    guard let dict = value as? [String : Any] else { return }
                    guard let title = dict["title"] as? String else { return }
                    guard let sourceUrl = dict["sourceUrl"] as? String else { return }
                    guard let id = dict["id"] as? Int else { return }
//                    guard let customOrder = dict["customOrder"] as? Int else { return }
                    let recipe = Recipe(title: title, sourceUrl: sourceUrl, id: id)
                    recipes.append(recipe)
                }
            }
            self.selectedRecipes = recipes
            
            var customRecipes = [LDRecipe]()
            if let selectedCustomRecipes = value["customRecipes"] as? [String : Any] {
                selectedCustomRecipes.forEach { (key, value) in
                    guard let dict = value as? [String : Any] else { return }
                    guard let title = dict["title"] as? String else { return }
                    guard let servings = dict["servings"] as? Int else { return }
                    guard let id = dict["id"] as? String else { return }
//                    guard let customOrder = dict["customOrder"] as? Int else { return }
                    
                    var customRecipe = LDRecipe()
                    customRecipe.title = title
                    customRecipe.servings = servings
                    customRecipe.id = id
//                    customRecipe.customOrder = customOrder
                    
                    // ingredients should be optional
                    if let ingredients = dict["ingredients"] as? [String : String] {
                        ingredients.forEach { (key, value) in
                            var customIngredient = LDIngredient()
                            customIngredient.name = key + value
                            customRecipe.ingredients.append(customIngredient)
                        }
                    }
                    if let downloadUrl = dict["downloadUrl"] as? String {
                        customRecipe.downloadUrl = downloadUrl
                    }
                    if let cookingSteps = dict["cookingSteps"] as? [String] {
                        cookingSteps.forEach { cookingStep in
                            customRecipe.cookingSteps.append(cookingStep)
                        }
                    }
                    if let comments = dict["comments"] as? String {
                        customRecipe.comments = comments
                    }
                    customRecipes.append(customRecipe)
                }
            }
            self.selectedCustomRecipes = customRecipes
            
            NotificationCenter.default.post(name: NSNotification.Name("updateTable"), object: nil)
        }) { (error) in
            NotificationCenter.default.post(name: NSNotification.Name("DownloadError"), object: nil)
        }
    }

    // MARK: Update Firebase Tasks

    func updateFirebaseTasks() {
        tasks.forEach { task in
//            Added isCustom in the parameters
            var parameters: [String : Any] = ["title" : task.taskName,
                                              "ownerName" : task.assignedPersonName,
                                              "ownerUid" : task.assignedPersonUid ?? "nil",
                                              "state" : task.taskState.rawValue,
                                              "isCustom" : task.isCustom,
                                              "parentRecipe" : task.parentRecipe]
            if let amount = task.metricAmount {
                parameters["metricAmount"] = amount
            }
            if let unit = task.metricUnit {
                parameters["metricUnit"] = unit
            }
                        
            let childUid = Database.database().reference().child(hostIdentifier).child("Events").child(firebaseEventUid).child("tasks").child(task.taskUid)
            childUid.updateChildValues(parameters, withCompletionBlock: { (error, reference) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    self.resetEvent()
                }
                
            })
        }
    }
    
    func updateFirebaseDate(_ dateTimestamp: Double) {
        self.dateTimestamp = dateTimestamp
        let parameters: [String : Any] = ["dateTimestamp" : dateTimestamp]
        let childUid = Database.database().reference().child(hostIdentifier).child("Events").child(firebaseEventUid)
        childUid.updateChildValues(parameters) { (error, reference) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.resetEvent()
            }
        }
    }
    
    func updateFirebaseServings() {
        let parameters: [String : Any] = ["servings" : servings]
        let childUid = Database.database().reference().child(hostIdentifier).child("Events").child(firebaseEventUid)
        childUid.updateChildValues(parameters) { (error, reference) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.resetEvent()
            }
        }
    }
    
    func cancelFirebaseEvent() {
        let cancelName = "Canceled: " + self.dinnerName
        self.dinnerName = cancelName
        self.tasks = []
        Database.database().reference().child(hostIdentifier).child("Events").child(self.firebaseEventUid).child("isCancelled").setValue(true)
        Database.database().reference().child(hostIdentifier).child("Events").child(self.firebaseEventUid).child("dinnerName").setValue(cancelName)
        Database.database().reference().child(hostIdentifier).child("Events").child(self.firebaseEventUid).child("tasks").setValue([:])
    }
    
    func getAssignedNewTasks() -> Int {
        let difference = tasks.difference(from: currentConversationTaskStates)
        var assignedStatusCount = 0
        difference.forEach { task in
            if task.taskState == .assigned {
                assignedStatusCount += 1
            }
        }
        return assignedStatusCount
    }
    
    func getCompletedTasks() -> Int {
        let difference = tasks.difference(from: currentConversationTaskStates)
        var completedStatusCount = 0
        difference.forEach { task in
            if task.taskState == .completed {
                completedStatusCount += 1
            }
        }
        return completedStatusCount
    }
    
    func getRemainingTasks() -> Int {
        var unassignedStatusCount = 0
        tasks.forEach { task in
            if task.taskState == .unassigned {
                unassignedStatusCount += 1
            }
        }
        return unassignedStatusCount
    }
    
    func updateAcceptStateToFirebase(hasAccepted: Invitation) {
        guard let currentUser = currentUser else {return}
        let identifier = currentUser.identifier

        let participantsParameters: [String: Any] = ["fullName": defaults.username,
                                                     "hasAccepted": currentUser.hasAccepted.rawValue,
                                                     "profilePicUrl" : defaults.profilePicUrl]
        Database.database().reference().child(hostIdentifier).child("Events").child(firebaseEventUid).child("participants").child(identifier).updateChildValues(participantsParameters)
        
    }
    

    
    
    
    func getNumberOfOnlineUsers(completion: @escaping (Int) -> Void) {
Database.database().reference().child(hostIdentifier).child("Events").child(firebaseEventUid).child("onlineUsers").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            completion(value)
        }
    }
    
    func addOnlineUser() {
        getNumberOfOnlineUsers { number in
            let updatedOnlineUsers = number + 1
            Database.database().reference().child(self.hostIdentifier).child("Events").child(self.firebaseEventUid).child("onlineUsers").setValue(updatedOnlineUsers)
        }
    }
    
    func removeOnlineUser() {
        getNumberOfOnlineUsers { number in
            let updatedOnlineUsers = number - 1
            Database.database().reference().child(self.hostIdentifier).child("Events").child(self.firebaseEventUid).child("onlineUsers").setValue(updatedOnlineUsers)
        }
    }
        

    // MARK: Event Task Management
    
    func calculateTaskCompletionPercentage() -> Double {
        var numberOfCompletedTasks = 0
        
        self.tasks.forEach { task in
            if task.taskState == .completed {
                numberOfCompletedTasks += 1
            }
        }
        
        let percentage : Double = Double(numberOfCompletedTasks)/Double(self.tasks.count)
        
        return percentage
    }
    
    func checkIsAllTasksCompleted() -> Bool {
        if calculateTaskCompletionPercentage() == 1 {
            return true
        } else {
            return false
        }
    }

}
