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
    let isloadingNextRecipes = MutableProperty<Bool>(false)
    
    var previouslySelectedRecipes : [Recipe]
    var previouslySelectedCustomRecipes : [LDRecipe]
    var previouslySelectedPublicRecipes : [LDRecipe]
    
    private let realmHelper = RealmHelper.shared
    private let searchManager = SearchManager.shared
    private let cloudManager = CloudManager.shared
    private let dataHelper = DataHelper.shared
    private let publicRecipeManager = PublicRecipeManager.shared
    
    private var customRecipeIds : [String] {
        return realmHelper.loadCustomRecipesAsLDRecipes().map { $0.id }
    }
    
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
            self.keyword.value = ""
            self.dataChangeObserver.send(value: ())
        }
        
        self.keyword.producer
        .take(duringLifetimeOf: self)
        .filter { !$0.isEmpty }
        .startWithValues { [weak self] keyword in
            guard let self = self else { return }
            switch self.searchType.value {
            case .customRecipes:
                self.customRecipes = self.customRecipes.filter { $0.title.lowercased().contains(keyword) || $0.keywords.contains(keyword) }
                self.dataChangeObserver.send(value: ())
            case .apiRecipes:
                self.searchApiRecipes(keyword)
            case .publicRecipes:
                self.searchPublicRecipes(keyword)
            }
        }
        
        loadRecipes()
    }
    
    func openRecipeCreationVCIfPossible() {
        self.cloudManager.userIsLoggedIn()
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
        return self.searchManager.checkEligibility()
            .flatMap(.concat) { [weak self] searchAllowed -> SignalProducer<[Recipe], LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                guard searchAllowed else {
                    return SignalProducer(error: LDError.apiRequestLimit)
                }
                return self.dataHelper.fetchSearchResultsBulk(keyword: keyword)
            }
    }
    
    private func loadDefaultRecipes() {
        self.dataHelper.loadDefaultRecipes()
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
    
    private func addSelectedPublicRecipesToPublicRecipes() {
        Event.shared.selectedPublicRecipes.forEach { recipe in
            if !self.publicRecipes.contains(where: {  $0.id == recipe.id }) {
                publicRecipes.append(recipe)
            }
        }
        publicRecipes.sort { $0.isPublicAndSelected && !$1.isPublicAndSelected }
    }
    
    private func loadCustomRecipes() {
        self.customRecipes = realmHelper.loadCustomRecipesAsLDRecipes()
        self.customRecipes.sort { $0.title.uppercased() < $1.title.uppercased() }
        self.customRecipes.sort { $0.isSelected && !$1.isSelected }
        self.dataChangeObserver.send(value: ())
    }
    
    private func loadPublicRecipes() {
        self.publicRecipeManager.fetchValidatedRecipes()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithValues({ [unowned self] recipes in
                self.publicRecipes = recipes.filter { !customRecipeIds.contains($0.id) }
                                            .filter { !Event.shared.selectedPublicRecipes.contains($0) }
                self.addSelectedPublicRecipesToPublicRecipes()
//                self.publicRecipes.sort { $0.isPublicAndSelected && !$1.isPublicAndSelected }
                self.dataChangeObserver.send(value: ())
            })
    }
    
    func loadFollowingPublicRecipes() {
        guard !self.isLoading.value else { return }
        guard !self.isloadingNextRecipes.value else { return }
        self.publicRecipeManager.fetchFollowingValidatedRecipes()
            .on(starting: { self.isloadingNextRecipes.value = true })
            .on(completed: { self.isloadingNextRecipes.value = false })
            .take(duringLifetimeOf: self)
            .startWithValues({ [unowned self] recipes in
                self.publicRecipes.append(contentsOf: recipes
                                            .filter { !customRecipeIds.contains($0.id) }
                                            .filter { !Event.shared.selectedPublicRecipes.contains($0) })
//                self.publicRecipes.sort { $0.isPublicAndSelected && !$1.isPublicAndSelected }
                self.addSelectedPublicRecipesToPublicRecipes()
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
    
    private func searchApiRecipes(_ keyword: String) {
        self.searchManager.resetNumberOfSearchesIfNeeded()
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
                    self.cloudManager.increaseUserSearchCountOnCloud()
                    self.recipes = recipes
                    self.dataChangeObserver.send(value: ())
                }
        }
    }
    
    private func searchPublicRecipes(_ keyword: String) {
        self.publicRecipeManager.searchForRecipes(keyword)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithValues({ [unowned self] recipes in
                self.publicRecipes = recipes.filter { !customRecipeIds.contains($0.id) }
                                            .filter { !Event.shared.selectedPublicRecipes.contains($0) }
                self.publicRecipes.sort { $0.isPublicAndSelected && !$1.isPublicAndSelected }
                self.dataChangeObserver.send(value: ())
            })
    }
    
    func searchFollowingPublicRecipes(_ keyword: String) {
        guard !self.isLoading.value else { return }
        guard !self.isloadingNextRecipes.value else { return }
        self.publicRecipeManager.searchForFollowingRecipes(keyword)
            .on(starting: { self.isloadingNextRecipes.value = true })
            .on(completed: { self.isloadingNextRecipes.value = false })
            .take(duringLifetimeOf: self)
            .startWithValues({ [unowned self] recipes in
                self.publicRecipes.append(contentsOf: recipes
                                            .filter { !customRecipeIds.contains($0.id) }
                                            .filter { !Event.shared.selectedPublicRecipes.contains($0) })
                self.publicRecipes.sort { $0.isPublicAndSelected && !$1.isPublicAndSelected }
                self.dataChangeObserver.send(value: ())
            })
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
