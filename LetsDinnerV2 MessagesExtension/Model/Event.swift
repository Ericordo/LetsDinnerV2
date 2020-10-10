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
import ReactiveSwift

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
    var selectedCustomRecipes = [LDRecipe]()
    
    // Helpful variable
    var tasksNeedUpdate : Bool {
        return !tasks.difference(from: currentConversationTaskStates).isEmpty
    }
    var servingsNeedUpdate : Bool {
        return servings != currentConversationServings
    }
    var servings = 2
    var currentConversationServings = 2
    var hostIdentifier = ""

    var participants = [User]()
    var tasks = [Task]()
    
    var allTasksCompleted : Bool {
        return calculateTaskCompletionPercentage() == 1
    }
    
    var isCancelled = false
    
    var localEventId = ""
    var eventCreation = false
    
     private let database = Database.database().reference()
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
        servings = 2
        currentConversationServings = 2
        isCancelled = false
        eventCreation = false
    }
    
    func prepareMessage(session: MSSession, eventCreation: Bool, action: SendAction) -> MSMessage {
        let bubbleManager = BubbleManager()
        let layout = MSMessageTemplateLayout()
        layout.image = Images.standardBackground
        layout.imageTitle = dinnerName
        layout.imageSubtitle = dinnerDate
        layout.caption = LabelStrings.caption
        let message: MSMessage = MSMessage(session: currentSession ?? MSSession())
//        message.layout = layout
        message.layout = bubbleManager.prepareMessageBubble()
        message.summaryText = summary
        message.md.set(value: dinnerName, forKey: "dinnerName")
        message.md.set(value: hostName, forKey: "hostName")
        message.md.set(value: dinnerLocation, forKey: "dinnerLocation")
        message.md.set(value: eventDescription, forKey: "eventDescription")
        message.md.set(value: dateTimestamp, forKey: "dateTimestamp")
        message.md.set(value: firebaseEventUid, forKey: "firebaseEventUid")
        
        if eventCreation {
            localEventId = UUID().uuidString
            if let hostID = currentUser?.identifier {
                message.md.set(value: hostID, forKey: "hostID")
            }
        } else {
            message.md.set(value: hostIdentifier, forKey: "hostID")
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
    }
    
    // MARK: FireBase Data
    
    private func createEventInfo(userID : String) -> [String : Any] {
        var eventInfo : [String : Any] = [DataKeys.eventName : dinnerName,
                                          DataKeys.hostName : hostName,
                                          DataKeys.dateTimestamp :dateTimestamp,
                                          DataKeys.eventLocation : dinnerLocation,
                                          DataKeys.eventDescription : eventDescription,
                                          DataKeys.hostID : userID,
                                          DataKeys.servings : servings,
                                          DataKeys.isCancelled : isCancelled,
                                          DataKeys.onlineUsers : 0]
        
        if !selectedRecipes.isEmpty {
            var recipesInfo : [String : Any] = [:]
            selectedRecipes.forEach { recipe in
                var recipeInfo : [String : Any] = [DataKeys.sourceUrl : recipe.sourceUrl ?? "",
                                                   DataKeys.id : recipe.id,
                                                   DataKeys.imageUrl : recipe.imageUrl ?? ""]
                if let cookingSteps = recipe.instructions {
                    recipeInfo[DataKeys.cookingSteps] = cookingSteps
                }
                recipesInfo[recipe.title] = recipeInfo
            }
            eventInfo[DataKeys.recipes] = recipesInfo
        }
        
        if !selectedCustomRecipes.isEmpty {
            var customRecipesInfo : [String : Any] = [:]
            selectedCustomRecipes.forEach { recipe in
                var recipeInfo : [String : Any] = [DataKeys.id : recipe.id,
                                                   DataKeys.servings : recipe.servings]
                var ingredientsInfo : [String : [String : Any]] = [:]
                recipe.ingredients.forEach { ingredient in
                    var ingredientInfo : [String : Any] = [:]
                    if let amount = ingredient.amount {
                        ingredientInfo[DataKeys.amount] = amount
                    }
                    ingredientInfo[DataKeys.unit] = ingredient.unit ?? ""
                    ingredientsInfo[ingredient.name] = ingredientInfo
                }
                recipeInfo[DataKeys.ingredients] = ingredientsInfo
                if let downloadUrl = recipe.downloadUrl {
                    recipeInfo[DataKeys.downloadUrl] = downloadUrl
                }

                if !recipe.comments.isEmpty {
                    recipeInfo[DataKeys.comments] = recipe.comments

                }
                if !recipe.cookingSteps.isEmpty {
                    recipeInfo[DataKeys.cookingSteps] = recipe.cookingSteps
                }
                customRecipesInfo[recipe.title] = recipeInfo
            }
            eventInfo[DataKeys.customRecipes] = customRecipesInfo
        }
        
        if !CustomOrderHelper.shared.customOrder.isEmpty {
            eventInfo[DataKeys.customOrder] = CustomOrderHelper.shared.customOrder
        }
        
        if !tasks.isEmpty {
            var tasksInfo : [String : Any] = [:]
            tasks.forEach { task in
                var taskInfo : [String : Any] = [DataKeys.title : task.taskName,
                                                 DataKeys.ownerName : task.assignedPersonName,
                                                 DataKeys.ownerUid : task.assignedPersonUid ?? "nil",
                                                 DataKeys.state : task.taskState.rawValue,
                                                 DataKeys.isCustom : task.isCustom,
                                                 DataKeys.parentRecipe : task.parentRecipe]
                if let amount = task.metricAmount {
                    taskInfo[DataKeys.metricAmount] = amount
                }
                if let unit = task.metricUnit {
                    taskInfo[DataKeys.metricUnit] = unit
                }
                let taskUid = UUID().uuidString
                tasksInfo[taskUid] = taskInfo
            }
            eventInfo[DataKeys.tasks] = tasksInfo
        }
        
        let participantParameters : [String : Any] = [DataKeys.fullName : defaults.username,
                                                      DataKeys.hasAccepted : Invitation.accepted.rawValue,
                                                      DataKeys.profilePicUrl : defaults.profilePicUrl]
        
        eventInfo[DataKeys.participants] = [userID : participantParameters]
        
        return eventInfo
    }
    
    func uploadEvent() -> SignalProducer<Void, LDError> {
        return SignalProducer { observer, _ in
            guard let userID = self.currentUser?.identifier else {
                observer.send(error: .noUserIdentifier)
                return
            }
            
            let eventInfo = self.createEventInfo(userID: userID)
            let eventId = UUID().uuidString
            self.firebaseEventUid = eventId
            
            self.database.child(userID).child(DataKeys.events).child(eventId).setValue(eventInfo) { error, _ in
                if error != nil {
                    observer.send(error: .eventUploadFail)
                } else {
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
        }
    }
    
    func deleteEvent() {
        guard let userID = self.currentUser?.identifier else { return }
        let eventID = self.firebaseEventUid
        guard !eventID.isEmpty else { return }
        self.database
        .child(userID)
        .child(DataKeys.events)
        .child(eventID)
        .removeValue()
    }
    
    private func parseEventInfo(_ value: [String : Any]) {
        self.hostIdentifier = value[DataKeys.hostID] as! String
        self.isCancelled = value[DataKeys.isCancelled] as! Bool
        let servings = value[DataKeys.servings] as! Int
        self.servings = servings
        self.currentConversationServings = servings
        let participants = value[DataKeys.participants] as! [String : Any]
        var users = [User]()
        participants.forEach { (key, value) in
            let dict = value as! [String : Any]
            let fullName = dict[DataKeys.fullName] as! String
            let hasAccepted = dict[DataKeys.hasAccepted] as! String
            let profilePicUrl = dict[DataKeys.profilePicUrl] as! String
            let user = User(identifier: key,
                            fullName: fullName,
                            hasAccepted: Invitation(rawValue: hasAccepted)!)
            user.profilePicUrl = profilePicUrl
            users.append(user)
        }
        self.participants = users
        
        let currentUser = self.participants.first { $0.identifier == self.currentUser?.identifier  }
        if let user = currentUser {
            self.currentUser?.hasAccepted = user.hasAccepted
        }
        
        if let currentTasks = value[DataKeys.tasks] as? [String : Any] {
            self.parseEventTasks(currentTasks)
        }
        
        if let customOrder = value[DataKeys.customOrder] as? [String : Int] {
            CustomOrderHelper.shared.customOrder = customOrder
        }
        
        var recipes = [Recipe]()
        if let selectedRecipes = value[DataKeys.recipes] as? [String : Any] {
            selectedRecipes.forEach { (key, value) in
                guard let dict = value as? [String : Any] else { return }
                guard let sourceUrl = dict[DataKeys.sourceUrl] as? String,
                    let id = dict[DataKeys.id] as? String,
                    let imageUrl = dict[DataKeys.imageUrl] as? String
                    else { return }
                
                var recipe = Recipe(title: key,
                                    sourceUrl: sourceUrl,
                                    id: id)
                recipe.imageUrl = imageUrl
                if let instructions = dict[DataKeys.cookingSteps] as? [String] {
                    recipe.instructions = instructions
                }
                recipes.append(recipe)
            }
        }
        self.selectedRecipes = recipes
        
        var customRecipes = [LDRecipe]()
        if let selectedCustomRecipes = value[DataKeys.customRecipes] as? [String : Any] {
            selectedCustomRecipes.forEach { (key, value) in
                guard let dict = value as? [String : Any] else { return }
                guard let servings = dict[DataKeys.servings] as? Int,
                    let id = dict[DataKeys.id] as? String
                    else { return }
                
                var customRecipe = LDRecipe(id: id,
                                            title: key,
                                            servings: servings)
                if let ingredients = dict[DataKeys.ingredients] as? [String : [String : Any]] {
                    ingredients.forEach { key, value in
                        let name = key
                        var amount: Double?
                        var unit: String?
                        if let ingredientAmount = value[DataKeys.amount] as? Double {
                            amount = ingredientAmount
                        }
                        if let ingredientUnit = value[DataKeys.unit] as? String, !ingredientUnit.isEmpty {
                            unit = ingredientUnit
                        }
                        let customIngredient = LDIngredient(name: name, amount: amount, unit: unit)
                        customRecipe.ingredients.append(customIngredient)
                    }
                }
                
                if let downloadUrl = dict[DataKeys.downloadUrl] as? String {
                    customRecipe.downloadUrl = downloadUrl
                }
                
                if let cookingSteps = dict[DataKeys.cookingSteps] as? [String] {
                    cookingSteps.forEach { value in
                        customRecipe.cookingSteps.append(value)
                    }
                }
                
                if let comments = dict[DataKeys.comments] as? [String] {
                    comments.forEach { value in
                        customRecipe.comments.append(value)
                    }
                }
                customRecipes.append(customRecipe)
            }
        }
        self.selectedCustomRecipes = customRecipes
    }
    
    func observeEvent() -> SignalProducer<Void, LDError> {
        return SignalProducer { observer, _ in
            self.database
                .child(self.hostIdentifier)
                .child(DataKeys.events)
                .child(self.firebaseEventUid)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let value = snapshot.value as? [String : Any] else {
                        let error = LDError.eventFetchingFail
                        observer.send(error: error)
                        return }
                self.parseEventInfo(value)
                NotificationCenter.default.post(name: NSNotification.Name("updateTable"), object: nil)
                observer.send(value: ())
                observer.sendCompleted()
            }
        }
    }
    
    private func fetchTasks() -> SignalProducer<Void, LDError> {
        return SignalProducer { observer, _ in
            self.database
                .child(self.hostIdentifier)
                .child(DataKeys.events)
                .child(self.firebaseEventUid)
                .child(DataKeys.tasks)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let value = snapshot.value as? [String : Any] else {
                        let error = LDError.eventFetchingFail
                        observer.send(error: error)
                        return }
                self.parseEventTasks(value)
                observer.send(value: ())
                observer.sendCompleted()
                
            }
        }
    }
    
    private func fetchServings() -> SignalProducer<Void, LDError> {
        return SignalProducer { observer, _ in
            self.database
                .child(self.hostIdentifier)
                .child(DataKeys.events)
                .child(self.firebaseEventUid)
                .child(DataKeys.servings)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let value = snapshot.value as? Int else {
                        let error = LDError.eventFetchingFail
                        observer.send(error: error)
                        return }
                self.servings = value
                observer.send(value: ())
                observer.sendCompleted()
            }
        }
    }
    
    func fetchTasksAndServings() -> SignalProducer<Void, LDError> {
        return fetchTasks().flatMap(.concat) { _ -> SignalProducer<Void, LDError> in
            return self.fetchServings()
        }
    }
    
    private func parseEventTasks(_ taskDict: [String : Any]) {
        self.currentConversationTaskStates.removeAll()
        var tasks = [Task]()
        taskDict.forEach { (key, value) in
            guard let dict = value as? [String : Any] else { return }
            guard let title = dict[DataKeys.title] as? String,
                let ownerName = dict[DataKeys.ownerName] as? String,
                let ownerUid = dict[DataKeys.ownerUid] as? String,
                let state = dict[DataKeys.state] as? Int,
                let isCustom = dict[DataKeys.isCustom] as? Bool,
                let parentRecipe = dict[DataKeys.parentRecipe] as? String
                else { return }

            let task = Task(taskName: title,
                            assignedPersonUid: ownerUid,
                            taskState: state,
                            taskUid: key,
                            assignedPersonName: ownerName,
                            isCustom: isCustom,
                            parentRecipe: parentRecipe)
            
            if let amount = dict[DataKeys.metricAmount] as? Double {
                task.metricAmount = amount
            }
            if let unit = dict[DataKeys.metricUnit] as? String {
                task.metricUnit = unit
            }
            tasks.append(task)

            // TODO: Fix this duplication at some point and make sure it works, update: seems necessary otherwise app doesnt see difference between current tasks and updated tasks by user when going back, keep it or implement a comparison method
            let newTask = Task(taskName: title,
                               assignedPersonUid: ownerUid,
                               taskState: state,
                               taskUid: key,
                               assignedPersonName: ownerName,
                               isCustom: isCustom,
                               parentRecipe: parentRecipe)

            if let amount = dict[DataKeys.metricAmount] as? Double {
                newTask.metricAmount = amount
            }
            if let unit = dict[DataKeys.metricUnit] as? String {
                newTask.metricUnit = unit
            }
            self.currentConversationTaskStates.append(newTask)
        }
        self.tasks = tasks
    }
    
    // MARK: Update Firebase Tasks
    
    func updateFirebaseTasks() -> SignalProducer<Void, LDError> {
        var parameters : [String : [String: Any]] = [:]
        tasks.forEach { task in
            var taskParameters: [String : Any] = [DataKeys.title: task.taskName,
                                                  DataKeys.ownerName : task.assignedPersonName,
                                                  DataKeys.ownerUid : task.assignedPersonUid ?? "nil",
                                                  DataKeys.state : task.taskState.rawValue,
                                                  DataKeys.isCustom : task.isCustom,
                                                  DataKeys.parentRecipe : task.parentRecipe]
            if let amount = task.metricAmount {
                taskParameters[DataKeys.metricAmount] = amount
            }
            if let unit = task.metricUnit {
                taskParameters[DataKeys.metricUnit] = unit
            }
            
            parameters[task.taskUid] = taskParameters
        }
        
        return SignalProducer { observer, _ in
            
            self.database.child(self.hostIdentifier)
                .child(DataKeys.events)
                .child(self.firebaseEventUid)
                .child(DataKeys.tasks)
                .updateChildValues(parameters, withCompletionBlock: { error, _ in
                    if error != nil {
                        observer.send(error: .taskUpdateFail)
                    } else {
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                })
        }
    }
    
    func updateFirebaseTasksAndServings() -> SignalProducer<Void, LDError> {
        return updateFirebaseServings().flatMap(.concat) { _ -> SignalProducer<Void, LDError> in
            return self.updateFirebaseTasks()
        }
    }

    func updateFirebaseDate(_ dateTimestamp: Double) -> SignalProducer<Void, LDError> {
        self.dateTimestamp = dateTimestamp
        let parameters: [String : Any] = [DataKeys.dateTimestamp : dateTimestamp]
        return SignalProducer { observer, _ in
            self.database.child(self.hostIdentifier)
                .child(DataKeys.events)
                .child(self.firebaseEventUid)
                .updateChildValues(parameters) { error, _ in
                    if error != nil {
                        observer.send(error: .rescheduleFail)
                    } else {
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                }
        }
    }
        
    private func updateFirebaseServings() -> SignalProducer<Void, LDError> {
        let parameters: [String : Any] = [DataKeys.servings : servings]
        return SignalProducer { observer, _ in
            self.database.child(self.hostIdentifier)
                .child(DataKeys.events)
                .child(self.firebaseEventUid)
                .updateChildValues(parameters) { error, _ in
                if error != nil {
                    observer.send(error: .taskUpdateFail)
                } else {
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
        }
    }
    
    func cancelFirebaseEvent() {
        self.dinnerName = LabelStrings.cancelledEvent + self.dinnerName
        self.tasks = []
        let eventNode = Database.database().reference().child(hostIdentifier).child(DataKeys.events).child(self.firebaseEventUid)
        eventNode.child(DataKeys.isCancelled).setValue(true)
        eventNode.child(DataKeys.eventName).setValue(self.dinnerName)
        eventNode.child(DataKeys.tasks).setValue([:])
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
    
    func updateFirebaseStatus(status: Invitation) -> SignalProducer<Void, LDError> {
        return SignalProducer { observer, _ in
            guard let user = self.currentUser else {
                observer.send(error: .noUserIdentifier)
                return
            }
            
            let participantsParameters: [String: Any] = [DataKeys.fullName: defaults.username,
                                                         DataKeys.hasAccepted: status.rawValue,
                                                         DataKeys.profilePicUrl : defaults.profilePicUrl]
            
            self.database.child(self.hostIdentifier)
                .child(DataKeys.events)
                .child(self.firebaseEventUid)
                .child(DataKeys.participants)
                .child(user.identifier)
                .updateChildValues(participantsParameters) { error, _ in
                    if error != nil {
                        observer.send(error: .statusUpdateFail)
                    } else {
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
            }
        }
    }
//    
//    func fetchUserStatus(completion: @escaping (Result<Invitation,LDError>) -> Void) {
//        guard let user = self.currentUser else {
//            DispatchQueue.main.async {
//                completion(.failure(.noUserIdentifier))
//            }
//        }
//        
//        
//        
//    }

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
}
