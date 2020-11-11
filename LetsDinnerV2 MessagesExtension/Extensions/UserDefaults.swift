//
//  UserDefaults.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

extension UserDefaults {
    var username : String {
        return lastName.isEmpty ? firstName : firstName + " " + lastName
    }
    
    var firstName: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }
    
    var lastName: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }
    
    var profilePicUrl: String {
        get { return string(forKey: Keys.profilePicUrl) ?? "" }
        set { set(newValue, forKey: Keys.profilePicUrl) }
    }
    
    var address: String {
        get { return string(forKey: Keys.address) ?? "" }
        set { set(newValue, forKey: Keys.address) }
    }
    
    var measurementSystem: String {
        get { return string(forKey: Keys.measurementSystem) ?? "" }
        set { set(newValue, forKey: Keys.measurementSystem) }
    }
    
    var searchType: String {
        get { return string(forKey: Keys.searchType) ?? "" }
        set { set(newValue, forKey: Keys.searchType) }
    }
    
    var addToCalendar : Bool {
        get { return bool(forKey: Keys.addEventCalendar) }
        set { set(newValue, forKey: Keys.addEventCalendar) }
    }
    
    func backupEventData() {
        guard Event.shared.firebaseEventUid.isEmpty else { return }
        let eventData = EventData(dinnerName: Event.shared.dinnerName,
                                  hostName: Event.shared.hostName,
                                  dateTimestamp: Event.shared.dateTimestamp,
                                  dinnerLocation: Event.shared.dinnerLocation,
                                  eventDescription: Event.shared.eventDescription,
                                  selectedRecipes: Event.shared.selectedRecipes,
                                  selectedCustomRecipes: Event.shared.selectedCustomRecipes,
                                  servings: Event.shared.servings,
                                  tasks: Event.shared.tasks,
                                  customOrder: CustomOrderHelper.shared.customOrder)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(eventData)
            self.set(data, forKey: Keys.eventBackup)
        } catch {
            
        }
    }
    
    func retrieveEventData() {
        if let data = self.value(forKey: Keys.eventBackup) as? Data {
            do {
                let decoder = JSONDecoder()
                let eventData = try decoder.decode(EventData.self, from: data)
                self.restoreEventData(eventData)
            } catch {
                
            }
        }
    }
    
    func eventDataIsValid() -> Bool {
        if let data = self.value(forKey: Keys.eventBackup) as? Data {
            do {
                let decoder = JSONDecoder()
                let eventData = try decoder.decode(EventData.self, from: data)
                if !eventData.dinnerName.isEmpty ||
                    !eventData.hostName.isEmpty ||
                    !eventData.dinnerLocation.isEmpty ||
                    !eventData.dateTimestamp.isZero {
                    return true
                } else {
                    return false
                }
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
    private func restoreEventData(_ eventData: EventData) {
        Event.shared.dinnerName = eventData.dinnerName
        Event.shared.hostName = eventData.hostName
        Event.shared.dateTimestamp = eventData.dateTimestamp
        Event.shared.dinnerLocation = eventData.dinnerLocation
        Event.shared.eventDescription = eventData.eventDescription
        Event.shared.selectedRecipes = eventData.selectedRecipes
        Event.shared.selectedCustomRecipes = eventData.selectedCustomRecipes
        Event.shared.servings = eventData.servings
        Event.shared.tasks = eventData.tasks
        CustomOrderHelper.shared.customOrder = eventData.customOrder
        self.set(nil, forKey: Keys.eventBackup)
    }
    
    func backupRecipeData(_ recipe: LDRecipe, imageData: Data?) {
        do {
            let encoder = JSONEncoder()
            let recipeData = try encoder.encode(recipe)
            self.set(recipeData, forKey: Keys.recipeBackup)
            if let data = imageData {
                self.set(data, forKey: Keys.recipePicBackup)
            }
        } catch {
            
        }
    }

    func deleteRecipeBackup() {
        self.set(nil, forKey: Keys.recipeBackup)
        self.set(nil, forKey: Keys.recipePicBackup)
    }
}
