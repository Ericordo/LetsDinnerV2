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
    var eventDescription = String()
    var selectedRecipes = [Recipe]()
    var selectedCustomRecipes = [CustomRecipe]()
//    var recipeTitles: String {
//          let titles = selectedRecipes.map { $0.title! }
//          return titles.joined(separator:", ")
//    }
    
    // Helpful Variable
    var isHostRegistered = false

    
    var servings = 2

    var hostIdentifier = ""

    var participants = [User]()
    var tasks = [Task]()
    
    // MARKS: - Functions
    
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
        isHostRegistered = false
        servings = 2
    }
    
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
            let firebaseChildUid = uploadEventToFirebase()
            message.md.set(value: firebaseChildUid, forKey: "firebaseEventUid")
        } else {
            message.md.set(value: firebaseEventUid, forKey: "firebaseEventUid")
        }
         return message
    }
    
    
    func uploadEventToFirebase() -> String {
        guard let userID = currentUser?.identifier else { return "error" }
        let reference = Database.database().reference()
//          let ingredients = selectedRecipes.map { $0.ingredientList }
          
        let childUid = reference.child("Events").childByAutoId()
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
                                                     "sourceUrl" : recipe.sourceUrl ?? ""]
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
                                                   "servings" : customRecipe.servings]

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
                var parameters : [String : Any] = ["title" : task.taskName, "ownerName" : task.assignedPersonName, "ownerUid" : task.assignedPersonUid ?? "nil", "state": task.taskState.rawValue, "isCustom" : task.isCustom, "parentRecipe" : task.parentRecipe]
                if let amount = task.metricAmount {
                    parameters["metricAmount"] = amount
                }
                if let unit = task.metricUnit {
                    parameters["metricUnit"] = unit
                }
                taskChild.setValue(parameters)
            }
        }

        let participantsParameters : [String : Any] = ["fullName" :                                                         defaults.username,
                                                       "hasAccepted" : currentUser?.hasAccepted.rawValue ?? "",
                                                       "profilePicUrl" : defaults.profilePicUrl]
       
//        currentUser?.hasAccepted = .accepted
        childUid.child("participants").child(userID).setValue(participantsParameters)
        
        let onlineUsersChild = childUid.child("onlineUsers")
        onlineUsersChild.setValue(0)
        
//        let onlineParticipantsParameters : [String : Int] = ["onlineUsers" : 0]
//        childUid.setValue(onlineParticipantsParameters)
        
        if let key = childUid.key {
            self.firebaseEventUid = key
            return key
        } else {
            return "error"
        }
        
      }
    
    
    
//    func observeEvent() {
//        Database.database().reference().child("Events").child(firebaseEventUid).observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [String : Any] else { return }
//            guard let hostID = value["hostID"] as? String else { return }
//            self.hostIdentifier = hostID
//
//            var users = [User]()
//            guard let participants = value["participants"] as? [String : Any] else { return }
//            participants.forEach { key, value in
//                guard let dict = value as? [String : Any] else { return }
//                guard let fullName = dict["fullName"] as? String else { return }
//                guard let hasAccepted = dict["hasAccepted"] as? Bool else { return }
//                // New line
//                guard let profilePicUrl = dict["profilePicUrl"] as? String else { return }
//                let user = User(identifier: key, fullName: fullName, hasAccepted: hasAccepted)
//                // New line
//                user.profilePicUrl = profilePicUrl
//                users.append(user)
//            }
//            self.participants = users
//
//            var tasks = [Task]()
//            guard let currentTasks = value["ingredients"] as? [String : Any] else { return }
//            currentTasks.forEach { (key, value) in
//                guard let dict = value as? [String : Any] else { return }
//                guard let title = dict["title"] as? String else { return }
//                guard let ownerName = dict["ownerName"] as? String else { return }
//                guard let ownerUid = dict["ownerUid"] as? String else { return }
//                guard let state = dict["state"] as? Int else { return }
//                let task = Task(taskName: title, assignedPersonUid: ownerUid, taskState: state, taskUid: key, assignedPersonName: ownerName)
//                tasks.append(task)
//                let newTask = Task(taskName: title, assignedPersonUid: ownerUid, taskState: state, taskUid: key, assignedPersonName: ownerName)
//                self.currentConversationTaskStates.append(newTask)
////                I don't understand why with the line below, the number of updated tasks is always 0, but it works fine with the 2 lines above. Debugger seems to always crash with the 2 lines above instead of line below
////                self.currentConversationTaskStates.append(task)
//            }
//            self.tasks = tasks
//
//            var recipes = [Recipe]()
//            guard let selectedRecipes = value["recipes"] as? [String : Any] else { return }
//            selectedRecipes.forEach { (key, value) in
//                guard let dict = value as? [String : Any] else { return }
//                guard let title = dict["title"] as? String else { return }
//                guard let sourceUrl = dict["sourceUrl"] as? String else { return }
//                let recipe = Recipe(title: title, sourceUrl: sourceUrl)
//                recipes.append(recipe)
//            }
//            self.selectedRecipes = recipes
//
//            NotificationCenter.default.post(name: NSNotification.Name("updateTable"), object: nil)
//        }
//    }
    
    
//        func observeEvent() {
//            // Run Two times when click on the event in message bubble
//
//            // Initiate user
//        Database.database().reference().child("Events").child(firebaseEventUid).observeSingleEvent(of: .value) { snapshot in
//                guard let value = snapshot.value as? [String : Any] else { return }
//                guard let hostID = value["hostID"] as? String else { return }
//                self.hostIdentifier = hostID
//
//                var users = [User]()
//                guard let participants = value["participants"] as? [String : Any] else { return }
//
//                participants.forEach { key, value in
//                    guard let dict = value as? [String : Any] else { return }
//                    guard let fullName = dict["fullName"] as? String else { return }
//                    guard let hasAccepted = dict["hasAccepted"] as? String else { return }
//                    guard let profilePicUrl = dict["profilePicUrl"] as? String else { return }
//
//                    let user = User(identifier: key,
//                                    fullName: fullName,
//                                    hasAccepted: Invitation(rawValue: hasAccepted)!)
//                    // New line
//                    user.profilePicUrl = profilePicUrl
//                    users.append(user)
//                }
//                self.participants = users
//
////                The line below fixes the bug of tasks duplicated when tapping on back button from taskList without submitting changes
//                self.currentConversationTaskStates.removeAll()
//                var tasks = [Task]()
////                Changed "ingredients" with "tasks" in line below
//                if let currentTasks = value["tasks"] as? [String : Any] {
//                    currentTasks.forEach { (key, value) in
//                        guard let dict = value as? [String : Any] else { return }
//                        guard let title = dict["title"] as? String else { return }
//                        guard let ownerName = dict["ownerName"] as? String else { return }
//                        guard let ownerUid = dict["ownerUid"] as? String else { return }
//                        guard let state = dict["state"] as? Int else { return }
//                        guard let isCustom = dict["isCustom"] as? Bool else { return }
//                        guard let parentRecipe = dict["parentRecipe"] as? String else { return }
//                        let task = Task(taskName: title, assignedPersonUid: ownerUid, taskState: state, taskUid: key, assignedPersonName: ownerName, isCustom: isCustom, parentRecipe: parentRecipe)
//                        if let amount = dict["metricAmount"] as? Double {
//                            task.metricAmount = amount
//                        }
//                        if let unit = dict["metricUnit"] as? String {
//                            task.metricUnit = unit
//                        }
//                        tasks.append(task)
//                        let newTask = Task(taskName: title, assignedPersonUid: ownerUid, taskState: state, taskUid: key, assignedPersonName: ownerName, isCustom: isCustom, parentRecipe: parentRecipe)
//                        if let amount = dict["metricAmount"] as? Double {
//                            newTask.metricAmount = amount
//                        }
//                        if let unit = dict["metricUnit"] as? String {
//                            newTask.metricUnit = unit
//                        }
//                        self.currentConversationTaskStates.append(newTask)
//                        //                I don't understand why with the line below, the number of updated tasks is always 0, but it works fine with the 2 lines above. Debugger seems to always crash with the 2 lines above instead of line below
//                        //                self.currentConversationTaskStates.append(task)
//                    }
//                }
//                self.tasks = tasks
//
//                var recipes = [Recipe]()
//                if let selectedRecipes = value["recipes"] as? [String : Any] {
//                    selectedRecipes.forEach { (key, value) in
//                        guard let dict = value as? [String : Any] else { return }
//                        guard let title = dict["title"] as? String else { return }
//                        guard let sourceUrl = dict["sourceUrl"] as? String else { return }
//                        let recipe = Recipe(title: title, sourceUrl: sourceUrl)
//                        recipes.append(recipe)
//                    }
//                }
//                self.selectedRecipes = recipes
//
//            var customRecipes = [CustomRecipe]()
//            if let selectedCustomRecipes = value["customRecipes"] as? [String : Any] {
//                selectedCustomRecipes.forEach { (key, value) in
//                    guard let dict = value as? [String : Any] else { return }
//                    guard let title = dict["title"] as? String else { return }
//                    guard let servings = dict["servings"] as? Int else { return }
//                    guard let ingredients = dict["ingredients"] as? [String : String] else { return }
//                    let customRecipe = CustomRecipe()
//                    customRecipe.title = title
//                    customRecipe.servings = servings
//                    ingredients.forEach { (key, value) in
//                        let customIngredient = CustomIngredient()
//                        customIngredient.name = key + value
//                        customRecipe.ingredients.append(customIngredient)
//                    }
//                    if let downloadUrl = dict["downloadUrl"] as? String {
//                        customRecipe.downloadUrl = downloadUrl
//                    }
//                    if let cookingSteps = dict["cookingSteps"] as? [String] {
//                        cookingSteps.forEach { cookingStep in
//                            customRecipe.cookingSteps.append(cookingStep)
//                        }
//                    }
//                    if let comments = dict["comments"] as? String {
//                        customRecipe.comments = comments
//                    }
//                    customRecipes.append(customRecipe)
//                }
//            }
//            self.selectedCustomRecipes = customRecipes
//
//                NotificationCenter.default.post(name: NSNotification.Name("updateTable"), object: nil)
//            }
//    }
    
    func observeEvent() {
        // Run Two times when click on the event in message bubble
        
        // Initiate user
        Database.database().reference().child("Events").child(firebaseEventUid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String : Any] else { return }
            guard let hostID = value["hostID"] as? String else { return }
            self.hostIdentifier = hostID
            
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
                    let recipe = Recipe(title: title, sourceUrl: sourceUrl)
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
                    let customRecipe = CustomRecipe()
                    customRecipe.title = title
                    customRecipe.servings = servings
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
        observeEvent()
    }
    
//    func updateFirebaseTasks() {
//        tasks.forEach { task in
//            let parameters: [String : Any] = ["title" : task.taskName, "ownerName" : task.assignedPersonName, "ownerUid" : task.assignedPersonUid ?? "nil", "state" : task.taskState.rawValue]
//            let childUid = Database.database().reference().child("Events").child(firebaseEventUid).child("ingredients").child(task.taskUid)
//            childUid.updateChildValues(parameters, withCompletionBlock: { (error, reference) in
//                self.resetEvent()
//            })
//        }
//    }
    
//    MARK: new updateFirebaseTasks func to add Custom Tasks
    

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
//            Replaced child[ingredients] by child[tasks]
                        
            let childUid = Database.database().reference().child("Events").child(firebaseEventUid).child("tasks").child(task.taskUid)
            childUid.updateChildValues(parameters, withCompletionBlock: { (error, reference) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    self.resetEvent()
                }
                
            })
        }
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

        let participantsParameters: [String: Any] = ["fullName":                                     defaults.username,
                                                     "hasAccepted": currentUser.hasAccepted.rawValue,
                                                     "profilePicUrl" : defaults.profilePicUrl]
        Database.database().reference().child("Events").child(firebaseEventUid).child("participants").child(identifier).updateChildValues(participantsParameters)
        
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
        Database.database().reference().child("Events").child(firebaseEventUid).child("onlineUsers").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            completion(value)
        }
    }
    
    func addOnlineUser() {
        getNumberOfOnlineUsers { number in
            let updatedOnlineUsers = number + 1
            Database.database().reference().child("Events").child(self.firebaseEventUid).child("onlineUsers").setValue(updatedOnlineUsers)
        }
    }
    
    func removeOnlineUser() {
        getNumberOfOnlineUsers { number in
            let updatedOnlineUsers = number - 1
            Database.database().reference().child("Events").child(self.firebaseEventUid).child("onlineUsers").setValue(updatedOnlineUsers)
        }
    }
    
       
 
    func deleteUserPicOnFirebase() {}
    func updateUserPicOnFirebase() {}

}
