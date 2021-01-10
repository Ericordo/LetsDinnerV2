//
//  RecipesViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

enum SearchType: String {
    case apiRecipes
    case customRecipes
    case publicRecipes
}

class RecipesViewModel {

    let keyword = MutableProperty<String>("")
    
    var recipes = [Recipe]()
//    var customRecipes : Results<CustomRecipe>?
//    var customSearchResults = [LDRecipe]()
    var customRecipes = [LDRecipe]()
    var publicRecipes = [LDRecipe]()

    let dataChangeSignal: Signal<Void, Never>
    private let dataChangeObserver: Signal<Void, Never>.Observer
    
    let errorSignal: Signal<LDError, Never>
    private let errorObserver: Signal<LDError, Never>.Observer
    
    let createRecipeSignal : Signal<Void, Never>
    private let createRecipeObserver : Signal<Void, Never>.Observer
    
    let searchType : MutableProperty<SearchType>
    let isLoading = MutableProperty<Bool>(false)
    
    var previouslySelectedRecipes : [Recipe]
    var previouslySelectedCustomRecipes : [LDRecipe]
    var previouslySelectedPublicRecipes : [LDRecipe]
    
    init() {
        self.searchType = MutableProperty(SearchType(rawValue: defaults.searchType) ?? .apiRecipes)
        previouslySelectedRecipes = Event.shared.selectedRecipes
        previouslySelectedCustomRecipes = Event.shared.selectedCustomRecipes
        previouslySelectedPublicRecipes = Event.shared.selectedPublicRecipes
                
        let (dataChangeSignal, dataChangeObserver) = Signal<Void, Never>.pipe()
        self.dataChangeSignal = dataChangeSignal
        self.dataChangeObserver = dataChangeObserver
        
        let (errorSignal, errorObserver) = Signal<LDError, Never>.pipe()
        self.errorSignal = errorSignal
        self.errorObserver = errorObserver
        
        let (createRecipeSignal, createRecipeObserver) = Signal<Void, Never>.pipe()
        self.createRecipeSignal = createRecipeSignal
        self.createRecipeObserver = createRecipeObserver
        
        self.searchType.producer
        .observe(on: UIScheduler())
        .take(duringLifetimeOf: self)
        .startWithValues { [weak self] searchType in
            guard let self = self else { return }
            defaults.searchType = searchType.rawValue
            self.dataChangeObserver.send(value: ())
        }
        
        self.keyword.producer
        .take(duringLifetimeOf: self)
        .filter { !$0.isEmpty }
        .startWithValues { [weak self] keyword in
            guard let self = self else { return }
            switch self.searchType.value {
            case .customRecipes:
//                self.customRecipes = self.customRecipes.filter("title CONTAINS[cd] %@", keyword)
                self.customRecipes = self.customRecipes.filter { $0.title.lowercased().contains(keyword.lowercased()) }
                self.dataChangeObserver.send(value: ())
            case .apiRecipes:
                SearchManager.shared.resetNumberOfSearchesIfNeeded()
                self.verifyEligibilityAndSearchIfPossible(keyword: keyword)
                    .on(starting: { self.isLoading.value = true })
                    .on(completed: { self.isLoading.value = false })
                    .take(duringLifetimeOf: self)
                    .startWithResult { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .failure(let error):
                            self.isLoading.value = false
                            self.errorObserver.send(value: error)
                        case .success(let recipes):
                            CloudManager.shared.increaseUserSearchCountOnCloud()
                            self.recipes = recipes
                            self.dataChangeObserver.send(value: ())
                        }
                }
            case .publicRecipes:
                self.publicRecipes = self.publicRecipes.filter { $0.title.lowercased().contains(keyword.lowercased()) }
                self.dataChangeObserver.send(value: ())
            }
        }
        
        loadRecipes()
    }
    
    func openRecipeCreationVCIfPossible() {
        CloudManager.shared.userIsLoggedIn()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.errorObserver.send(value: error)
                case .success(let userIsLoggedIn):
                    if userIsLoggedIn {
                        self.createRecipeObserver.send(value: ())
                    } else {
                        self.errorObserver.send(value: .notSignedInCloud)
                    }
                }
        }
    }
    
    private func verifyEligibilityAndSearchIfPossible(keyword: String) -> SignalProducer<[Recipe], LDError> {
        return SearchManager.shared.checkEligibility()
            .flatMap(.concat) { searchAllowed -> SignalProducer<[Recipe], LDError> in
            guard searchAllowed else {
                return SignalProducer.init(error: LDError.apiRequestLimit)
            }
            return DataHelper.shared.fetchSearchResultsBulk(keyword: keyword)
        }
    }
    
    private func loadDefaultRecipes() {
        DataHelper.shared.loadDefaultRecipes()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.errorObserver.send(value: error)
                case .success(let defaultRecipes):
                    self.recipes = defaultRecipes
                    self.addSelectedRecipesToDefaultRecipes()
                    self.dataChangeObserver.send(value: ())
                }
        }
    }
    
    private func addSelectedRecipesToDefaultRecipes() {
        Event.shared.selectedRecipes.forEach { recipe in
            if !self.recipes.contains(where: {  $0.id == recipe.id }) {
                recipes.append(recipe)
            }
        }
        recipes.sort { $0.isSelected && !$1.isSelected }
    }
    
    private func loadCustomRecipes() {
        let recipes = RealmHelper.shared.loadCustomRecipes()
        self.customRecipes.removeAll()
        recipes?.forEach({ recipe in
            self.customRecipes.append(RealmHelper.shared.convertRLRecipeToLDRecipe(recipe))
        })
        self.customRecipes.sort { $0.title.uppercased() < $1.title.uppercased() }
        self.customRecipes.sort { $0.isSelected && !$1.isSelected }
        self.dataChangeObserver.send(value: ())
    }
    
    private func loadPublicRecipes() {
        PublicRecipeManager.shared.fetchRecipes()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithValues({ [unowned self] recipes in
                self.publicRecipes = recipes
                self.publicRecipes.sort { $0.title.uppercased() < $1.title.uppercased() }
                self.publicRecipes.sort { $0.isPublicAndSelected && !$1.isPublicAndSelected }
                self.dataChangeObserver.send(value: ())
            })
    }
    
    func loadRecipes() {
        switch self.searchType.value {
        case .apiRecipes:
            loadDefaultRecipes()
        case .customRecipes:
            loadCustomRecipes()
        case .publicRecipes:
            loadPublicRecipes()
        }
    }
    
    func prepareTasks() {
        // Remove
        Event.shared.tasks.forEach { task in
            if !task.isCustom &&
                !Event.shared.selectedRecipes.contains(where: { $0.title == task.parentRecipe }) &&
                !Event.shared.selectedCustomRecipes.contains(where: { $0.title == task.parentRecipe }) &&
                !Event.shared.selectedPublicRecipes.contains(where: { $0.title == task.parentRecipe }) &&
                task.parentRecipe != LabelStrings.misc
            {
                let index = Event.shared.tasks.firstIndex { $0.taskName == task.taskName }
                Event.shared.tasks.remove(at: index!)
            }
        }
        
        // Add the New Recipes
        var newRecipes = [Recipe]()
        var newCustomRecipes = [LDRecipe]()
        var newPublicRecipes = [LDRecipe]()
        
        if previouslySelectedRecipes.isEmpty {
            newRecipes = Event.shared.selectedRecipes
        } else {
            Event.shared.selectedRecipes.forEach { recipe in
                if !previouslySelectedRecipes.contains(where: { recipe.title == $0.title }) {
                    newRecipes.append(recipe)
                }
                if previouslySelectedRecipes.contains(where: { recipe.title == $0.title }) &&
                    !Event.shared.tasks.contains(where: { recipe.title == $0.parentRecipe }) {
                    newRecipes.append(recipe)
                }
            }
        }
        
        if previouslySelectedCustomRecipes.isEmpty {
            newCustomRecipes = Event.shared.selectedCustomRecipes
        } else {
            Event.shared.selectedCustomRecipes.forEach { recipe in
                if !previouslySelectedCustomRecipes.contains(where: { recipe.id == $0.id }) {
                    newCustomRecipes.append(recipe)
                }
                if previouslySelectedCustomRecipes.contains(where: { recipe.title == $0.title }) &&
                    !Event.shared.tasks.contains(where: { recipe.title == $0.parentRecipe }) {
                    newCustomRecipes.append(recipe)
                }
            }
        }
        
        if previouslySelectedPublicRecipes.isEmpty {
            newPublicRecipes = Event.shared.selectedPublicRecipes
        } else {
            Event.shared.selectedPublicRecipes.forEach { recipe in
                if !previouslySelectedPublicRecipes.contains(where: { recipe.id == $0.id }) {
                    newPublicRecipes.append(recipe)
                }
                if previouslySelectedPublicRecipes.contains(where: { recipe.title == $0.title }) &&
                    !Event.shared.tasks.contains(where: { recipe.title == $0.parentRecipe }) {
                    newPublicRecipes.append(recipe)
                }
            }
        }
        
        // According to api and custom
        newRecipes.forEach { recipe in
            let recipeName = recipe.title
            let servings = Double(recipe.servings ?? 2)
            let ingredients = recipe.ingredientList
            
            if defaults.measurementSystem == "imperial" {
                ingredients?.forEach({ ingredient in
                    if let name = ingredient.name?.capitalizingFirstLetter(), let amount = ingredient.usAmount, let unit = ingredient.usUnit {
                        let task = Task(taskName: name,
                                        assignedPersonUid: "nil",
                                        taskState: TaskState.unassigned.rawValue,
                                        taskUid: "nil",
                                        assignedPersonName: "nil",
                                        isCustom: false,
                                        parentRecipe: recipeName)
                        task.metricAmount = (amount * 2) / Double(servings)
                        task.metricUnit = unit
                        task.servings = 2
                        Event.shared.tasks.append(task)
                    }
                })
            } else {
                ingredients?.forEach({ ingredient in
                    if let name = ingredient.name?.capitalizingFirstLetter(), let amount = ingredient.metricAmount, let unit = ingredient.metricUnit {
                        let task = Task(taskName: name,
                                        assignedPersonUid: "nil",
                                        taskState: TaskState.unassigned.rawValue,
                                        taskUid: "nil",
                                        assignedPersonName: "nil",
                                        isCustom: false,
                                        parentRecipe: recipeName)
                        task.metricAmount = (amount * 2) / Double(servings)
                        task.metricUnit = unit
                        task.servings = 2
                        Event.shared.tasks.append(task)
                    }
                })
            }
        }
        
        newCustomRecipes.forEach { customRecipe in
            let recipeName = customRecipe.title
            let servings = Double(customRecipe.servings)
            let customIngredients = customRecipe.ingredients
            
            customIngredients.forEach { customIngredient in
                let task = Task(taskName: customIngredient.name,
                                assignedPersonUid: "nil",
                                taskState: TaskState.unassigned.rawValue,
                                taskUid: "nil",
                                assignedPersonName: "nil",
                                isCustom: false, parentRecipe: recipeName)
                task.metricUnit = customIngredient.unit
                if let amount = customIngredient.amount {
                    if Int(amount) != 0 {
                        task.metricAmount = (amount * 2) / servings
                    }
                }
                task.servings = 2
                Event.shared.tasks.append(task)
            }
        }
        
        newPublicRecipes.forEach { publicRecipe in
            let recipeName = publicRecipe.title
            let servings = Double(publicRecipe.servings)
            let publicIngredients = publicRecipe.ingredients
            
            publicIngredients.forEach { publicIngredient in
                let task = Task(taskName: publicIngredient.name,
                                assignedPersonUid: "nil",
                                taskState: TaskState.unassigned.rawValue,
                                taskUid: "nil",
                                assignedPersonName: "nil",
                                isCustom: false, parentRecipe: recipeName)
                task.metricUnit = publicIngredient.unit
                if let amount = publicIngredient.amount {
                    if Int(amount) != 0 {
                        task.metricAmount = (amount * 2) / servings
                    }
                }
                task.servings = 2
                Event.shared.tasks.append(task)
            }
        }
    }
}
