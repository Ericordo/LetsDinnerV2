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
import FirebaseStorage
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
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    var eventIsExpired: Bool {
        let currentDateTimestamp = Date().timeIntervalSince1970
        return dateTimestamp < currentDateTimestamp
    }
    
    var eventDescription = String()
    var selectedRecipes = [Recipe]()
    var selectedCustomRecipes = [CustomRecipe]()
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
    
    var isCancelled = false
    var isSyncAlertShownInTaskListVC = false
    
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
    
    // MARK: Message Data
    func prepareMessage(session: MSSession, eventCreation: Bool) -> MSMessage {
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "bubbleBackground")
        layout.imageTitle = dinnerName
        layout.imageSubtitle = dinnerDate
        layout.caption = "Tap to view Dinner! "
        
        let message: MSMessage = MSMessage(session: currentSession ?? MSSession())
        message.layout = layout
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
            let firebaseChildUid = uploadEventToFirebase()
            message.md.set(value: firebaseChildUid, forKey: "firebaseEventUid")
        } else {
            message.md.set(value: firebaseEventUid, forKey: "firebaseEventUid")
        }
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
                                                    "customOrder":recipe.customOrder]
                  recipeChild.setValue(parameters)
              }
          }
        
        if !selectedCustomRecipes.isEmpty {
            selectedCustomRecipes.forEach { customRecipe in
                var ingredients = [String : String]()
                customRecipe.ingredients.forEach { ingredient in
                    if let amount = ingredient.amount.value {
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
                                                   "customOrder" : customRecipe.customOrder]

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
        
        // Initiate user
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
            
            var recipes = [Recipe]()
            
            if let selectedRecipes = value["recipes"] as? [String : Any] {
                selectedRecipes.forEach { (key, value) in
                    guard let dict = value as? [String : Any] else { return }
                    guard let title = dict["title"] as? String else { return }
                    guard let sourceUrl = dict["sourceUrl"] as? String else { return }
                    guard let customOrder = dict["customOrder"] as? Int else { return }
                    let recipe = Recipe(title: title, sourceUrl: sourceUrl, customOrder: customOrder)
                    recipes.append(recipe)
                }
            }
            self.selectedRecipes = recipes
            
            var customRecipes = [CustomRecipe]()
            if let selectedCustomRecipes = value["customRecipes"] as? [String : Any] {
                selectedCustomRecipes.forEach { (key, value) in
                    guard let dict = value as? [String : Any] else { return }
                    guard let title = dict["title"] as? String else { return }
                    guard let servings = dict["servings"] as? Int else { return }
                    guard let ingredients = dict["ingredients"] as? [String : String] else { return }
                    guard let customOrder = dict["customOrder"] as? Int else { return }
                    
                    let customRecipe = CustomRecipe()
                    customRecipe.title = title
                    customRecipe.servings = servings
                    customRecipe.customOrder = customOrder
                    
                    ingredients.forEach { (key, value) in
                        let customIngredient = CustomIngredient()
                        customIngredient.name = key + value
                        customRecipe.ingredients.append(customIngredient)
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

    
    
    
    // MARK: Update Firebase Task

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
    
    func updateAcceptStateToFirebase(hasAccepted: Invitation) {
        guard let currentUser = currentUser else {return}
        let identifier = currentUser.identifier

        let participantsParameters: [String: Any] = ["fullName": defaults.username,
                                                     "hasAccepted": currentUser.hasAccepted.rawValue,
                                                     "profilePicUrl" : defaults.profilePicUrl]
        Database.database().reference().child(hostIdentifier).child("Events").child(firebaseEventUid).child("participants").child(identifier).updateChildValues(participantsParameters)
        
    }
    
//    func saveUserPicToFirebase(_ image: UIImage?, completion: @escaping ((_ url:String?)->())) {
//        guard let imageToSave = image else { return }
//        guard let imageData = imageToSave.jpegData(compressionQuality: 0.5) else { return }
//
//        let storage = Storage.storage().reference()
//
//        let storageRef = storage.child("ProfilePictures").child("UserProfilePic").child(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)
//
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpg"
//
//        storageRef.putData(imageData, metadata: metadata) { (metaData, error) in
//            if error != nil {
//                completion(nil)
//            }
//            storageRef.downloadURL { (url, error ) in
//                if error != nil {
//                    completion(nil)
//                }
//                if let downloadUrl = url?.absoluteString {
//                    print("URL", downloadUrl)
//                    completion(downloadUrl)
//                }
//            }
//        }
//    }
    
    func saveUserPicToFirebase(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        
        let storage = Storage.storage().reference()
        
        let storageRef = storage.child("ProfilePictures").child("UserProfilePic").child(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metadata) { (metaData, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
            }
            storageRef.downloadURL { (url, error ) in
                if error != nil {
                    DispatchQueue.main.async {
                        completion(.failure(error!))
                    }
                }
                if let downloadUrl = url?.absoluteString {
                    print("URL", downloadUrl)
                    DispatchQueue.main.async {
                        completion(.success(downloadUrl))
                    }
                    
                }
            }
        }
    }
    
    func saveRecipePicToFirebase(_ image: UIImage, id: String, completion: @escaping (Result<String, Error>) -> Void) {
         
          guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
              
              let storage = Storage.storage().reference()
              
              let storageRef = storage.child("RecipePictures").child("RecipePicture").child(id)
              
              let metadata = StorageMetadata()
              metadata.contentType = "image/jpg"
              
              storageRef.putData(imageData, metadata: metadata) { (metaData, error) in
                  if error != nil {
                      DispatchQueue.main.async {
                          completion(.failure(error!))
                      }
                  }
                  storageRef.downloadURL { (url, error ) in
                      if error != nil {
                          DispatchQueue.main.async {
                              completion(.failure(error!))
                          }
                      }
                      if let downloadUrl = url?.absoluteString {
                          print("URL", downloadUrl)
                          DispatchQueue.main.async {
                              completion(.success(downloadUrl))
                          }
                          
                      }
                  }
              }
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
        
    func deleteUserPicOnFirebase() {}
    func updateUserPicOnFirebase() {}
    
    // MARK: Recipe Managing Order (Local Algo)
    
    func findTheIndexOfLastCustomOrderFromAllRecipes() -> Int? {
        
        var lastIndex = 0
        // Loop throught the customOrder two arrays

        let maxNumInSelectedRecipes = selectedRecipes.map{$0.customOrder}.max()
        let totalNumberOfSelectedRecipes = selectedRecipes.count
        
        let maxNumInSelectedCustomRecipes = selectedCustomRecipes.map{$0.customOrder}.max()
        let totalNumberOfselectedCustomRecipes = selectedCustomRecipes.count
        
        // Cross checking
//        print(maxNumInSelectedRecipes)
//        print("= checK \(totalNumberOfSelectedRecipes)")
        
        // Loop through selectedCustomRecipes
        if let maxNumInSelectedRecipes = maxNumInSelectedRecipes {
            lastIndex = maxNumInSelectedRecipes
        }
        
        if let maxNumInSelectedCustomRecipes = maxNumInSelectedCustomRecipes {
            if lastIndex < maxNumInSelectedCustomRecipes {
                lastIndex = maxNumInSelectedCustomRecipes
            }
        }
            
        return lastIndex
    }
    
    func reassignCustomOrderAfterRemoval(recipeType: SearchType, index: Int) {
        
        /* find the global custom order (done)
            turn the global custom order to 0 (done)
            -1 the global customorder which larger than the deleted one
        */
        
        var customOrder = 0
        
        if recipeType == .apiRecipes {
            customOrder = self.selectedRecipes[index].customOrder
            self.selectedRecipes[index].customOrder = 0
        } else {
            customOrder = self.selectedCustomRecipes[index].customOrder
            self.selectedCustomRecipes[index].customOrder = 0
        }
        
        if !selectedRecipes.isEmpty {
            for (index, recipe) in selectedRecipes.enumerated() {
                if recipe.customOrder > customOrder {
                    selectedRecipes[index].customOrder -= 1
                }
            }
        }
        
        if !selectedCustomRecipes.isEmpty {
            for (index, recipe) in selectedCustomRecipes.enumerated() {
                if recipe.customOrder > customOrder {
                    selectedCustomRecipes[index].customOrder -= 1
                }
            }
        }
    }
    
    func reassignCustomOrderAfterReorder(sourceCustomOrder: Int, destinationCustomOrder: Int, movedObject: Any) {
        
        /* Save the object
        // Find the object orginal customOrder
        // Find the object destination customOrder
        // Chnage it to desination
         */
        
        var movedObjectIndex = 0
        var movedObjectOwnTypeDestinationIndex = 0
        
        // locate the movedObjectIndex
        if movedObject is Recipe {
            for index in 0 ... selectedRecipes.count - 1 {
                if selectedRecipes[index].customOrder == sourceCustomOrder {
                    movedObjectIndex = index
                    break
                }
            }
        } else {
            for index in 0 ... selectedCustomRecipes.count - 1 {
                if selectedCustomRecipes[index].customOrder == sourceCustomOrder {
                    movedObjectIndex = index
                    break
                }
            }
        }

        print(sourceCustomOrder,destinationCustomOrder)
        
        if sourceCustomOrder < destinationCustomOrder {
            // MARK: Moving Foward
            
            // Find the recipes that need to move
            let recipes = selectedRecipes.filter { $0.customOrder > sourceCustomOrder && $0.customOrder <= destinationCustomOrder}
            let customRecipes = selectedCustomRecipes.filter { $0.customOrder > sourceCustomOrder && $0.customOrder <= destinationCustomOrder}
            
            let customOrderApiRecipesNeedToBeUpdated = Array(recipes.map{$0.customOrder})
            let customOrderCustomRecipesNeedToBeUpdated = Array(customRecipes.map{$0.customOrder})
            
            // - 1 the selected Array (previous ones)
            if !customOrderApiRecipesNeedToBeUpdated.isEmpty{
                for customOrder in customOrderApiRecipesNeedToBeUpdated {
                      for index in 0 ... selectedRecipes.count - 1 {
                          // locate destintation index in own type of array（first)
                          
                          if movedObject is Recipe {
                              if selectedRecipes[index].customOrder == customOrderApiRecipesNeedToBeUpdated.last {
                                  movedObjectOwnTypeDestinationIndex = index
                              }
                          }
        
                          if selectedRecipes[index].customOrder == customOrder {
                              selectedRecipes[index].customOrder -= 1
                              break
                          }
                      }
                  }
            }
            
            if !customOrderCustomRecipesNeedToBeUpdated.isEmpty {
                for customOrder in customOrderCustomRecipesNeedToBeUpdated {
                    for index in 0 ... selectedCustomRecipes.count - 1 {
                        // locate destintation index （first)
                        if movedObject is CustomRecipe {
                            if selectedCustomRecipes[index].customOrder == customOrderCustomRecipesNeedToBeUpdated.last {
                                movedObjectOwnTypeDestinationIndex = index
                            }
                        }
                        
                        
                        if selectedCustomRecipes[index].customOrder == customOrder {
                            selectedCustomRecipes[index].customOrder -= 1
                            break
                        }
                    }
                }
            }
            
//            print(movedObjectOwnTypeDestinationIndex)
        
        } else {
            // MARK: Moving backward
            let recipes = selectedRecipes.filter { $0.customOrder < sourceCustomOrder && $0.customOrder >= destinationCustomOrder}
            let customRecipes = selectedCustomRecipes.filter { $0.customOrder < sourceCustomOrder && $0.customOrder >= destinationCustomOrder}
            
            let customOrderApiRecipesToBeUpdated = Array(recipes.map{$0.customOrder})
            let customOrderCustomRecipesToBeUpdated = Array(customRecipes.map{$0.customOrder})
            
            // + 1 customOrder for previous
            if !customOrderApiRecipesToBeUpdated.isEmpty {
                for customOrder in customOrderApiRecipesToBeUpdated {
                    for index in (0 ... selectedRecipes.count - 1).reversed(){
                        // locate destintation index
                        if movedObject is Recipe {
                            if selectedRecipes[index].customOrder == customOrderApiRecipesToBeUpdated.first {
                                movedObjectOwnTypeDestinationIndex = index
                            }
                        }
                        
                        if selectedRecipes[index].customOrder == customOrder {
                            selectedRecipes[index].customOrder += 1
                            break
                        }
                        
                    }
                }
            }
            
            if !customOrderCustomRecipesToBeUpdated.isEmpty {
                for customOrder in customOrderCustomRecipesToBeUpdated {
                    for index in (0 ... selectedCustomRecipes.count - 1).reversed(){
                        // locate destintation index
                        if movedObject is Recipe {
                            if selectedCustomRecipes[index].customOrder == customOrderCustomRecipesToBeUpdated.first {
                                movedObjectOwnTypeDestinationIndex = index
                            }
                        }
                        
                        if selectedCustomRecipes[index].customOrder == customOrder {
                            selectedCustomRecipes[index].customOrder += 1
                            break
                        }
                        
                    }
                }
            }
            
        }
        
        // Reorder the movedObject customOrder (removed object)
        if movedObject is Recipe {
            selectedRecipes.remove(at: movedObjectIndex)
            selectedRecipes.insert(movedObject as! Recipe, at: movedObjectOwnTypeDestinationIndex)
            
            // add the customOrder to the newly inserted recipe
            selectedRecipes[movedObjectOwnTypeDestinationIndex].customOrder = destinationCustomOrder
        } else {
            selectedCustomRecipes.remove(at: movedObjectIndex)
            selectedCustomRecipes.insert(movedObject as! CustomRecipe, at: movedObjectOwnTypeDestinationIndex)
            
            selectedCustomRecipes[movedObjectOwnTypeDestinationIndex].customOrder = destinationCustomOrder
        }
        
        sortAscRecipeByCustomOrder()

    }
    
    func sortAscRecipeByCustomOrder() {
        Event.shared.selectedRecipes = Event.shared.selectedRecipes.sorted(by: { $0.customOrder < $1.customOrder})
        Event.shared.selectedCustomRecipes = Event.shared.selectedCustomRecipes.sorted(by: {$0.customOrder < $1.customOrder})
    }
    
    func mergeAllRecipesTitles(selectedRecipes: [Recipe], selectedCustomRecipes: [CustomRecipe]) -> [String] {
        var allRecipeTitles = [String]()
        let totalNumberOfRecipes = selectedRecipes.count + selectedCustomRecipes.count

        for customOrder in 0 ... totalNumberOfRecipes {
            if !selectedRecipes.isEmpty {
                for index in 0 ... selectedRecipes.count - 1 {
                    if selectedRecipes[index].customOrder == customOrder {
                        allRecipeTitles.append(selectedRecipes[index].title ?? "")
                        break
                    }
                }
            }
            
            if !selectedCustomRecipes.isEmpty {
                for index in 0 ... selectedCustomRecipes.count - 1 {
                    if selectedCustomRecipes[index].customOrder == customOrder {
                        allRecipeTitles.append(selectedCustomRecipes[index].title)
                        break
                    }
                }
            }
        }
        return allRecipeTitles
    }
    

}
