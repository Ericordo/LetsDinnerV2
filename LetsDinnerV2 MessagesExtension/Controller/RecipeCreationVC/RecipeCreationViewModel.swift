//
//  RecipeCreationViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 09/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift
import CloudKit

class RecipeCreationViewModel {
    
    let recipeSignal : Signal<Result<Void, LDError>, Never>
    private let recipeObserver : Signal<Result<Void, LDError>, Never>.Observer
    
    let doneActionSignal : Signal<Void, Never>
    private let doneActionObserver : Signal<Void, Never>.Observer
    
    let editActionSignal : Signal<Void, Never>
    private let editActionObserver : Signal<Void, Never>.Observer
    
    let isLoading = MutableProperty<Bool>(false)
    
    let recipe : LDRecipe?
    
    let recipePicData : MutableProperty<Data?>
    let downloadUrl : MutableProperty<String?>
    let recipeName : MutableProperty<String>
    let servings : MutableProperty<Int>
    let ingredients = MutableProperty<[LDIngredient]>([])
    let steps = MutableProperty<[String]>([])
    let comments = MutableProperty<[String]>([])
    
    let creationMode : MutableProperty<Bool>
    
    var editingAllowed : Bool {
        return StepStatus.currentStep == .recipesVC && self.recipe != nil
    }
    
    private var informationIsValid : Bool {
        return !self.recipeName.value.isEmpty
    }
    
    private var informationIsEmpty : Bool {
        return self.recipePicData.value == nil
            && recipeName.value.isEmpty
            && ingredients.value.isEmpty
            && steps.value.isEmpty
            && comments.value.isEmpty
    }
    
    init(with recipe: LDRecipe? = nil, creationMode: Bool) {
        self.recipe = recipe
        self.recipePicData = MutableProperty(nil)
        self.downloadUrl = MutableProperty(nil)
        self.recipeName = MutableProperty<String>("")
        self.servings = MutableProperty<Int>(2)
        self.creationMode = MutableProperty(creationMode)
        
        let (recipeSignal, recipeObserver) = Signal<Result<Void, LDError>, Never>.pipe()
        self.recipeSignal = recipeSignal
        self.recipeObserver = recipeObserver

        let (doneActionSignal, doneActionObserver) = Signal<Void, Never>.pipe()
        self.doneActionSignal = doneActionSignal
        self.doneActionObserver = doneActionObserver
        
        let (editActionSignal, editActionObserver) = Signal<Void, Never>.pipe()
        self.editActionSignal = editActionSignal
        self.editActionObserver = editActionObserver
        
        if let recipe = recipe {
            self.displayRecipe(recipe)
        }
    }
    
    private func displayRecipe(_ recipe: LDRecipe) {
        self.recipeName.value = recipe.title
        self.servings.value = recipe.servings
        self.downloadUrl.value = recipe.downloadUrl
        self.ingredients.value = recipe.ingredients
        self.steps.value = recipe.cookingSteps
        self.comments.value = recipe.comments
    }
    
    func didTapDone() {
        if !self.creationMode.value {
            self.recipeObserver.send(value: .success(()))
        } else if self.recipe == nil {
            if self.informationIsEmpty {
                self.recipeObserver.send(value: .success(()))
            } else {
                self.doneActionObserver.send(value: ())
            }
        } else {
            if let recipe = self.recipe, recipe == self.prepareRecipe()  {
                if recipe.downloadUrl == nil && self.recipePicData.value != nil {
                    self.doneActionObserver.send(value: ())
                } else {
                    self.recipeObserver.send(value: .success(()))
                }
            } else {
                self.doneActionObserver.send(value: ())
            }
        }
    }
    
    func didTapEdit() {
        CloudManager.shared.userIsLoggedIn()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                case .success(let userIsLoggedIn):
                    if userIsLoggedIn {
                        self.editActionObserver.send(value: ())
                    } else {
                        self.recipeObserver.send(value: .failure(.notSignedInCloud))
                    }
                }
        }
    }

    private func prepareRecipe() -> LDRecipe {
        return LDRecipe(title: recipeName.value,
        servings: self.servings.value,
        downloadUrl: self.downloadUrl.value,
        cookingSteps: self.steps.value,
        comments: self.comments.value,
        ingredients: self.ingredients.value)
 }

    func saveRecipe() {
        guard informationIsValid else {
            self.recipeObserver.send(value: .failure(.recipeNameMissing))
            return
        }
        CloudManager.shared.userIsLoggedIn()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                case .success(let userIsLoggedIn):
                    if userIsLoggedIn {
                        if let data = self.recipePicData.value {
                            self.saveRecipePictureAndInfo(data, id: UUID().uuidString)
                            return
                        }
                        let recipe = self.prepareRecipe()
                        self.saveRecipeInformation(recipe)
                    } else {
                        self.recipeObserver.send(value: .failure(.notSignedInCloud))
                    }
                }
        }
    }
    
    func updateRecipe() {
        guard informationIsValid else {
            self.recipeObserver.send(value: .failure(.recipeNameMissing))
            return
        }
        CloudManager.shared.userIsLoggedIn()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                case .success(let userIsLoggedIn):
                    if userIsLoggedIn {
                        guard let currentRecipe = self.recipe else { return }
                        if let data = self.recipePicData.value {
                            self.updateRecipePictureAndInfo(data, id: currentRecipe.id)
                            return
                        }
                        var newRecipe = self.prepareRecipe()
                        newRecipe.id = currentRecipe.id
                        self.updateRecipeInformation(currentRecipe, newRecipe)
                    } else {
                        self.recipeObserver.send(value: .failure(.notSignedInCloud))
                    }
                }
        }
    }
    
    func deleteRecipe(_ recipe: LDRecipe) {
        CloudManager.shared.userIsLoggedIn()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                case .success(let userIsLoggedIn):
                    if userIsLoggedIn {
                        CloudManager.shared.deleteRecipeFromCloud(recipe)
                            .on(starting: { self.isLoading.value = true })
                            .on(completed: { self.isLoading.value = false })
                            .observe(on: UIScheduler())
                            .take(duringLifetimeOf: self)
                            .startWithResult { result in
                                switch result {
                                case .success():
                                    RealmHelper.shared.deleteRecipeInRealm(recipe)
                                        .startWithCompleted {
                                            if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == recipe.id }) {
                                                Event.shared.selectedCustomRecipes.remove(at: index)
                                            }
                                            self.recipeObserver.send(value: .success(()))
                                    }
                                case .failure(let error):
                                    self.isLoading.value = false
                                    self.recipeObserver.send(value: .failure(error))
                                }
                        }
                    } else {
                        self.recipeObserver.send(value: .failure(.notSignedInCloud))
                    }
                }
        }
    }
    
    private func saveRecipePictureAndInfo(_ imageData: Data, id: String) {
        ImageHelper.shared.saveRecipePicToFirebase(imageData, id: id)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                case .success(let url):
                    var recipe = self.prepareRecipe()
                    recipe.id = id
                    recipe.downloadUrl = url
                    self.saveRecipeInformation(recipe)
                }
        }
    }
    
    private func saveRecipeInformation(_ recipe: LDRecipe) {
        CloudManager.shared.saveRecipeAndIngredientsOnCloud(recipe)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithResult { result in
                switch result {
                case .success(let recordID):
                    RealmHelper.shared.saveRecipeInRealm(recipe, recordID: recordID.recordName)
                        .startWithCompleted {
                            self.recipeObserver.send(value: .success(()))
                    }
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                }
        }
    }
    
    private func updateRecipePictureAndInfo(_ imageData: Data, id: String) {
        ImageHelper.shared.saveRecipePicToFirebase(imageData, id: id)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                case .success(let url):
                    guard let currentRecipe = self.recipe else { return }
                    var newRecipe = self.prepareRecipe()
                    newRecipe.id = id
                    newRecipe.downloadUrl = url
                    self.updateRecipeInformation(currentRecipe, newRecipe)
                }
        }
    }
    
    private func updateRecipeInformation(_ currentRecipe: LDRecipe, _ newRecipe: LDRecipe) {
        CloudManager.shared.updateRecipeInCloud(currentRecipe, newRecipe)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithResult { result in
                switch result {
                case .success():
                    RealmHelper.shared.updateRecipeInRealm(currentRecipe, newRecipe)
                        .startWithCompleted {
                           self.recipeObserver.send(value: .success(()))
                    }
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                }
        }
    }
}
