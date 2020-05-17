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
                let recipeInfo : [String : Any] = [DataKeys.sourceUrl : recipe.sourceUrl ?? "",
                                                   DataKeys.id : recipe.id ?? 0]
                recipesInfo[recipe.title ?? "Unknown title"] = recipeInfo
            }
            eventInfo[DataKeys.recipes] = recipesInfo
        }
        
        if !selectedCustomRecipes.isEmpty {
            var customRecipesInfo : [String : Any] = [:]
            selectedCustomRecipes.forEach { recipe in
                var recipeInfo : [String : Any] = [DataKeys.id : recipe.id,
                                                   DataKeys.servings : recipe.servings]
                var ingredientsInfo : [String : String] = [:]
                recipe.ingredients.forEach { ingredient in
                    if let amount = ingredient.amount {
                        ingredientsInfo[ingredient.name] = ", \(amount) \(ingredient.unit ?? "")"
                    } else {
                        ingredientsInfo[ingredient.name] = String()
                    }
                }
                recipeInfo[DataKeys.ingredients] = ingredientsInfo
                if let downloadUrl = recipe.downloadUrl {
                    recipeInfo[DataKeys.downloadUrl] = downloadUrl
                }
                if let comments = recipe.comments {
                    recipeInfo[DataKeys.comments] = comments
                }
                if !recipe.cookingSteps.isEmpty {
                    recipeInfo[DataKeys.cookingSteps] = recipe.cookingSteps
                }
                customRecipesInfo[recipe.title] = recipeInfo
            }
            eventInfo[DataKeys.customRecipes] = customRecipesInfo
        }
        
        #warning("Please refactor this, why using a set when we can directly store a dict?. Write a method that directly returns the dict instead of assigning it to a property that is then stored")
        if !CustomOrderHelper.shared.customOrder.isEmpty {
            CustomOrderHelper.shared.convertedCustomOrderForFirebaseStorage = CustomOrderHelper.shared.convertingTupleToArray(from: CustomOrderHelper.shared.customOrder)
            eventInfo[DataKeys.customOrder] = CustomOrderHelper.shared.convertedCustomOrderForFirebaseStorage
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
        
        self.currentConversationTaskStates.removeAll()
        var tasks = [Task]()
        if let currentTasks = value[DataKeys.tasks] as? [String : Any] {
            currentTasks.forEach { (key, value) in
                guard let dict = value as? [String : Any] else { return }
                guard let title = dict[DataKeys.title] as? String,
                    let ownerName = dict[DataKeys.ownerName] as? String,
                    let ownerUid = dict[DataKeys.ownerUid] as? String,
                    let state = dict[DataKeys.state] as? Int,
                    let isCustom = dict[DataKeys.isCustom] as? Bool,
                    let parentRecipe = dict[DataKeys.parentRecipe] as? String
                    else { return }
                
                #warning("fix this duplication and make sure it works")
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
        }
        self.tasks = tasks
        
        if let customOrder = value[DataKeys.customOrder] as? [String] {
            CustomOrderHelper.shared.customOrder = CustomOrderHelper.shared.convertingArrayToTuple(from: customOrder)
        }
        
        var recipes = [Recipe]()
        if let selectedRecipes = value[DataKeys.recipes] as? [String : Any] {
            selectedRecipes.forEach { (key, value) in
                guard let dict = value as? [String : Any] else { return }
                guard let sourceUrl = dict[DataKeys.sourceUrl] as? String,
                    let id = dict[DataKeys.id] as? Int
                    else { return }
                
                let recipe = Recipe(title: key,
                                    sourceUrl: sourceUrl,
                                    id: id)
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
                
                if let ingredients = dict[DataKeys.ingredients] as? [String : String] {
                    ingredients.forEach { key, value in
                        let customIngredient = LDIngredient(name: key + value)
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
                if let comments = dict[DataKeys.comments] as? String {
                    customRecipe.comments = comments
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
                    #warning("To modify this notif, but it seems to be necessary for the TaskSummaryCell")
                NotificationCenter.default.post(name: NSNotification.Name("updateTable"), object: nil)
                observer.send(value: ())
                observer.sendCompleted()
            }
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
        
    // MARK: Recipe Managing Order (Local Algo)
    
//    func findTheIndexOfLastCustomOrderFromAllRecipes() -> Int? {
//
//        var lastIndex = 0
//        // Loop throught the customOrder two arrays
//
//        let maxNumInSelectedRecipes = selectedRecipes.map{$0.customOrder}.max()
//        let totalNumberOfSelectedRecipes = selectedRecipes.count
//
//        let maxNumInSelectedCustomRecipes = selectedCustomRecipes.map{$0.customOrder}.max()
//        let totalNumberOfselectedCustomRecipes = selectedCustomRecipes.count
//
//        // Cross checking
////        print(maxNumInSelectedRecipes)
////        print("= checK \(totalNumberOfSelectedRecipes)")
//
//        // Loop through selectedCustomRecipes
//        if let maxNumInSelectedRecipes = maxNumInSelectedRecipes {
//            lastIndex = maxNumInSelectedRecipes
//        }
//
//        if let maxNumInSelectedCustomRecipes = maxNumInSelectedCustomRecipes {
//            if lastIndex < maxNumInSelectedCustomRecipes {
//                lastIndex = maxNumInSelectedCustomRecipes
//            }
//        }
//
//        return lastIndex
//    }
//
//    func reassignCustomOrderAfterRemoval(recipeType: SearchType, index: Int) {
//
//        /* find the global custom order (done)
//            turn the global custom order to 0 (done)
//            -1 the global customorder which larger than the deleted one
//        */
//
//        var customOrder = 0
//
//        if recipeType == .apiRecipes {
//            customOrder = self.selectedRecipes[index].customOrder
//            self.selectedRecipes[index].customOrder = 0
//        } else {
//            customOrder = self.selectedCustomRecipes[index].customOrder
//            self.selectedCustomRecipes[index].customOrder = 0
//        }
//
//        if !selectedRecipes.isEmpty {
//            for (index, recipe) in selectedRecipes.enumerated() {
//                if recipe.customOrder > customOrder {
//                    selectedRecipes[index].customOrder -= 1
//                }
//            }
//        }
//
//        if !selectedCustomRecipes.isEmpty {
//            for (index, recipe) in selectedCustomRecipes.enumerated() {
//                if recipe.customOrder > customOrder {
//                    selectedCustomRecipes[index].customOrder -= 1
//                }
//            }
//        }
//    }
//
//    func reassignCustomOrderAfterReorder(sourceCustomOrder: Int, destinationCustomOrder: Int, movedObject: Any) {
//
//        /* Save the object
//         Find the object orginal customOrder
//         Find the object destination customOrder
//         Chnage it to desination
//         */
//
//        var movedObjectIndex = 0
//        var movedObjectOwnTypeDestinationIndex = 0
//
//        // locate the movedObjectIndex
//        if movedObject is Recipe {
//            for index in 0 ... selectedRecipes.count - 1 {
//                if selectedRecipes[index].customOrder == sourceCustomOrder {
//                    movedObjectIndex = index
//                    break
//                }
//            }
//        } else {
//            for index in 0 ... selectedCustomRecipes.count - 1 {
//                if selectedCustomRecipes[index].customOrder == sourceCustomOrder {
//                    movedObjectIndex = index
//                    break
//                }
//            }
//        }
//
//        print(sourceCustomOrder,destinationCustomOrder)
//
//        if sourceCustomOrder < destinationCustomOrder {
//            // MARK: Moving Foward
//
//            // Find the recipes that need to move
//            let recipes = selectedRecipes.filter { $0.customOrder > sourceCustomOrder && $0.customOrder <= destinationCustomOrder}
//            let customRecipes = selectedCustomRecipes.filter { $0.customOrder > sourceCustomOrder && $0.customOrder <= destinationCustomOrder}
//
//            let customOrderApiRecipesNeedToBeUpdated = Array(recipes.map{$0.customOrder})
//            let customOrderCustomRecipesNeedToBeUpdated = Array(customRecipes.map{$0.customOrder})
//
//            // - 1 the selected Array (previous ones)
//            if !customOrderApiRecipesNeedToBeUpdated.isEmpty{
//                for customOrder in customOrderApiRecipesNeedToBeUpdated {
//                      for index in 0 ... selectedRecipes.count - 1 {
//                          // locate destintation index in own type of array（first)
//
//                          if movedObject is Recipe {
//                              if selectedRecipes[index].customOrder == customOrderApiRecipesNeedToBeUpdated.last {
//                                  movedObjectOwnTypeDestinationIndex = index
//                              }
//                          }
//
//                          if selectedRecipes[index].customOrder == customOrder {
//                              selectedRecipes[index].customOrder -= 1
//                              break
//                          }
//                      }
//                  }
//            }
//
//            if !customOrderCustomRecipesNeedToBeUpdated.isEmpty {
//                for customOrder in customOrderCustomRecipesNeedToBeUpdated {
//                    for index in 0 ... selectedCustomRecipes.count - 1 {
//                        // locate destintation index （first)
//                        if movedObject is CustomRecipe {
//                            if selectedCustomRecipes[index].customOrder == customOrderCustomRecipesNeedToBeUpdated.last {
//                                movedObjectOwnTypeDestinationIndex = index
//                            }
//                        }
//
//
//                        if selectedCustomRecipes[index].customOrder == customOrder {
//                            selectedCustomRecipes[index].customOrder -= 1
//                            break
//                        }
//                    }
//                }
//            }
//
////            print(movedObjectOwnTypeDestinationIndex)
//
//        } else {
//            // MARK: Moving backward
//            let recipes = selectedRecipes.filter { $0.customOrder < sourceCustomOrder && $0.customOrder >= destinationCustomOrder}
//            let customRecipes = selectedCustomRecipes.filter { $0.customOrder < sourceCustomOrder && $0.customOrder >= destinationCustomOrder}
//
//            let customOrderApiRecipesToBeUpdated = Array(recipes.map{$0.customOrder})
//            let customOrderCustomRecipesToBeUpdated = Array(customRecipes.map{$0.customOrder})
//
//            // + 1 customOrder for previous
//            if !customOrderApiRecipesToBeUpdated.isEmpty {
//                for customOrder in customOrderApiRecipesToBeUpdated {
//                    for index in (0 ... selectedRecipes.count - 1).reversed(){
//                        // locate destintation index
//                        if movedObject is Recipe {
//                            if selectedRecipes[index].customOrder == customOrderApiRecipesToBeUpdated.first {
//                                movedObjectOwnTypeDestinationIndex = index
//                            }
//                        }
//
//                        if selectedRecipes[index].customOrder == customOrder {
//                            selectedRecipes[index].customOrder += 1
//                            break
//                        }
//
//                    }
//                }
//            }
//
//            if !customOrderCustomRecipesToBeUpdated.isEmpty {
//                for customOrder in customOrderCustomRecipesToBeUpdated {
//                    for index in (0 ... selectedCustomRecipes.count - 1).reversed(){
//                        // locate destintation index
//                        if movedObject is Recipe {
//                            if selectedCustomRecipes[index].customOrder == customOrderCustomRecipesToBeUpdated.first {
//                                movedObjectOwnTypeDestinationIndex = index
//                            }
//                        }
//
//                        if selectedCustomRecipes[index].customOrder == customOrder {
//                            selectedCustomRecipes[index].customOrder += 1
//                            break
//                        }
//
//                    }
//                }
//            }
//
//        }
//
//        // Reorder the movedObject customOrder (removed object)
//        if movedObject is Recipe {
//            selectedRecipes.remove(at: movedObjectIndex)
//            selectedRecipes.insert(movedObject as! Recipe, at: movedObjectOwnTypeDestinationIndex)
//
//            // add the customOrder to the newly inserted recipe
//            selectedRecipes[movedObjectOwnTypeDestinationIndex].customOrder = destinationCustomOrder
//        } else {
//            selectedCustomRecipes.remove(at: movedObjectIndex)
//            selectedCustomRecipes.insert(movedObject as! CustomRecipe, at: movedObjectOwnTypeDestinationIndex)
//
//            selectedCustomRecipes[movedObjectOwnTypeDestinationIndex].customOrder = destinationCustomOrder
//        }
//
//        sortAscRecipeByCustomOrder()
//
//    }
//
//    func sortAscRecipeByCustomOrder() {
//        Event.shared.selectedRecipes = Event.shared.selectedRecipes.sorted(by: { $0.customOrder < $1.customOrder})
//        Event.shared.selectedCustomRecipes = Event.shared.selectedCustomRecipes.sorted(by: {$0.customOrder < $1.customOrder})
//    }
//
//    func mergeAllRecipesTitles(selectedRecipes: [Recipe], selectedCustomRecipes: [CustomRecipe]) -> [String] {
//        var allRecipeTitles = [String]()
//        let totalNumberOfRecipes = selectedRecipes.count + selectedCustomRecipes.count
//
//        guard totalNumberOfRecipes > 0 else { return [] }
//        for customOrder in 1 ... totalNumberOfRecipes {
//            if !selectedRecipes.isEmpty {
//                for index in 0 ... selectedRecipes.count - 1 {
//                    if selectedRecipes[index].customOrder == customOrder {
//                        allRecipeTitles.append(selectedRecipes[index].title ?? "")
//                        break
//                    }
//                }
//            }
//
//            if !selectedCustomRecipes.isEmpty {
//                for index in 0 ... selectedCustomRecipes.count - 1 {
//                    if selectedCustomRecipes[index].customOrder == customOrder {
//                        allRecipeTitles.append(selectedCustomRecipes[index].title)
//                        break
//                    }
//                }
//            }
//        }
//        return allRecipeTitles
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
    
    func checkIsAllTasksCompleted() -> Bool {
        if calculateTaskCompletionPercentage() == 1 {
            return true
        } else {
            return false
        }
    }

}
