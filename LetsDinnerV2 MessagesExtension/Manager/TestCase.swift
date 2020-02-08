//
//  File.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 29/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import Foundation

// Initate all variable for event

class testCase {

    static func createCaseOne() -> Event {
        let event = Event()
        
        event.dinnerName = "Test Case 1 with a very long long long name"
        event.hostName = "Sexy Baby"
        event.eventDescription = "I am so curious what is happening in the kitchen with a French guy making lasagna with some bottle of milk ready to put some ginger into the pomodoro. Everyone keeps singing an American Song which called The victory of the Vitnamese having Pho for dinner drinking a huge tank of beer showing a very impatient face to the Koreans"
        event.dinnerLocation = "-18/F Basement"
        event.dateTimestamp = 0
        
        // Event.task and event.selectedRecipe


        func grabRecipe() {
            DataHelper.shared.loadPredefinedRecipes { recipes in
                          event.selectedRecipes = recipes
                          
                          var array = [Recipe]()
                          array = Array(event.selectedRecipes[0...0])
                          event.selectedRecipes = array
                                  
                print(Thread.isMainThread)
                          
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
                      }
                  
        }
        
       
        grabRecipe()
        
        return event
    }
    
    
}

