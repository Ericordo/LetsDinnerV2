//
//  File.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 29/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

let testManager = TestManager.sharedInstance
private var _SingletonSharedInstance = TestManager()

class TestManager {
    
    var isTesting = false

    public class var sharedInstance: TestManager {
        return _SingletonSharedInstance
    }
    
    // ==========================================================================
    
    // MARK: Test Configuration
    var isDarkModeOn = false
    
    var isHost = false
    var isStatusPending = true // isHost need to be false
    var isUserAcceptedEvent = true // isStatusPending need to be false
    
    // ===========================================================================
    
    func darkModeOn(view: UIViewController) {
            if #available(iOS 13.0, *) {
                self.isDarkModeOn ? (view.overrideUserInterfaceStyle = .dark) : (view.overrideUserInterfaceStyle = .light)
            }
        
    }
    
    // For status
    func createHostStatus() {
        if self.isHost {
//            Event.shared.hostIdentifier = user.indentifier
        } else {
            Event.shared.hostIdentifier = "123123"
        }
    }
    
    func createPendingStatus(user: User) {
        if self.isStatusPending {
            user.hasAccepted = .pending
        }
    }
    
    func createAcceptStatus(user: User) {
        self.isUserAcceptedEvent ? (user.hasAccepted = .accepted) : (user.hasAccepted = .declined)
    }

    static func createCaseOne() -> Event {
        let event = Event()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        event.dinnerName = "Test Case 1 with a very long long long name"
        event.hostName = "Sexy Baby"
        event.eventDescription = "I am so curious what is happening in the kitchen with a French guy making lasagna with some bottle of milk ready to put some ginger into the pomodoro. Everyone keeps singing an American Song which called The victory of the Vitnamese having Pho for dinner drinking a huge tank of beer showing a very impatient face to the Koreans"
        event.dinnerLocation = "A very Longggg longgggg longgg dinner location"
        event.dateTimestamp = Double(Date.currentTimeStamp)
        
        // Event.task and event.selectedRecipe

        func grabRecipe() {
            
            print("GrabRecipe")
            
            DispatchQueue.global().async {
                DataHelper.shared.loadPredefinedRecipes { recipes in
                    
                    event.selectedRecipes = recipes
                      
                    var array = [Recipe]()
                    array = Array(event.selectedRecipes[0...0])
                    event.selectedRecipes = array
                                                                                
                      event.selectedRecipes.forEach { recipe in
                          let recipeName = recipe.title ?? ""
                          let servings = Double(recipe.servings ?? 2)
                          let ingredients = recipe.ingredientList
                          
                          if defaults.measurementSystem == "imperial" {
                              ingredients?.forEach({ ingredient in
                                  if let name = ingredient.name?.capitalizingFirstLetter(), let amount = ingredient.usAmount, let unit = ingredient.usUnit {
                                      let task = Task(taskName: name, assignedPersonUid: "nil", taskState: TaskState.unassigned.rawValue, taskUid: "nil", assignedPersonName: "nil", isCustom: false, parentRecipe: recipeName)
                                      task.metricAmount = (amount * 2) / Double(servings)
                                      task.metricUnit = unit
                                      task.servings = 2
                                      Event.shared.tasks.append(task)
                                  }
                              })
                              
                          } else {
                              ingredients?.forEach({ ingredient in
                                  if let name = ingredient.name?.capitalizingFirstLetter(), let amount = ingredient.metricAmount, let unit = ingredient.metricUnit {
                                      let task = Task(taskName: name, assignedPersonUid: "nil", taskState: TaskState.unassigned.rawValue, taskUid: "nil", assignedPersonName: "nil", isCustom: false, parentRecipe: recipeName)
                                      task.metricAmount = (amount * 2) / Double(servings)
                                      task.metricUnit = unit
                                      task.servings = 2
                                      Event.shared.tasks.append(task)
                                  }
                              })
                          }
                        }
                    
                    dispatchGroup.leave()
                }
            }
            
        
        }
       
        grabRecipe()
        
        dispatchGroup.wait()
        
        return event
    }
    
    
    static func quickFillIn() -> Event {
        let event = Event()
        
        event.dinnerName = "Quick Dinner (Finish in 10 mins)"
        event.hostName = "Obama"
        event.eventDescription = "Oh no. I love monopoly"
        event.dinnerLocation = "TBC"
        event.dateTimestamp = Double(Date.currentTimeStamp)
        
        return event
    }
    
}

