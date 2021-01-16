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
    let keywords = MutableProperty<[String]>([])
    let isPublic : MutableProperty<Bool>
    
    let creationMode : MutableProperty<Bool>
    
    private let realmHelper = RealmHelper.shared
    private let cloudManager = CloudManager.shared
    private let publicRecipeManager = PublicRecipeManager.shared
    private let imageHelper = ImageHelper.shared
    
    var editingAllowed : Bool {
        return StepStatus.currentStep == .recipesVC && self.recipe != nil && self.recipe?.recordID != nil
    }
    
    var keywordContainerHidden : Bool {
        if StepStatus.currentStep == .recipesVC {
            if creationMode.value || self.editingAllowed {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
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
            && keywords.value.isEmpty
    }
    
    init(with recipe: LDRecipe? = nil, creationMode: Bool) {
        self.recipe = recipe
        self.recipePicData = MutableProperty(nil)
        self.downloadUrl = MutableProperty(nil)
        self.recipeName = MutableProperty<String>("")
        self.servings = MutableProperty<Int>(2)
        self.creationMode = MutableProperty(creationMode)
        self.isPublic = MutableProperty(true)
        
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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(backupRecipe),
                                               name: Notification.Name(rawValue: "DidResignActive"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(backupRecipe),
                                               name: Notification.Name(rawValue: "WillTransition"),
                                               object: nil)
    }
    
    private func displayRecipe(_ recipe: LDRecipe) {
        self.recipeName.value = recipe.title
        self.servings.value = recipe.servings
        self.downloadUrl.value = recipe.downloadUrl
        self.ingredients.value = recipe.ingredients
        self.steps.value = recipe.cookingSteps
        self.comments.value = recipe.comments
        self.keywords.value = recipe.keywords
        self.isPublic.value = recipe.isPublic
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

    // MARK: Save recipe
    func saveRecipe() {
        self.savingFlow()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                case .success():
                    self.recipeObserver.send(value: .success(()))
                }
            }
    }
    
    private func prepareRecipe() -> LDRecipe {
        return LDRecipe(title: recipeName.value,
                        servings: self.servings.value,
                        downloadUrl: self.downloadUrl.value,
                        cookingSteps: self.steps.value,
                        comments: self.comments.value,
                        ingredients: self.ingredients.value,
                        keywords: self.keywords.value,
                        isPublic: self.isPublic.value)
    }
    
    private func saveRecipePictureIfNeeded(recipeId: String? = nil) -> SignalProducer<(String?, String), LDError> {
        let id = recipeId ?? UUID().uuidString
        if let data = self.recipePicData.value {
            return self.imageHelper.saveRecipePicToFirebase(data, id: id).map { ($0, id) }
        } else {
            return SignalProducer(value: (nil, id))
        }
    }
    
    private func savingFlow() -> SignalProducer<Void, LDError> {
        guard informationIsValid else { return SignalProducer(error: .recipeNameMissing) }
        return self.cloudManager.userIsLoggedIn()
            .flatMap(.concat) { [weak self] userIsLoggedIn -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                guard userIsLoggedIn else { return SignalProducer(error: .notSignedInCloud) }
                return self.saveRecipePictureIfNeeded()
            .flatMap(.concat) { [weak self] (downloadUrl, recipeId) -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                var recipe = self.prepareRecipe()
                recipe.id = recipeId
                recipe.downloadUrl = downloadUrl
                return self.cloudManager.saveRecipeAndIngredientsOnCloud(recipe)
            .flatMap(.concat) { [weak self] recordID -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                return self.realmHelper.saveRecipeInRealm(recipe, recordID: recordID.recordName)
            .flatMap(.concat) { [weak self] _ -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                defaults.deleteRecipeBackup()
                if self.isPublic.value {
                    return self.publicRecipeManager.saveRecipe(recipe)
                } else {
                    return SignalProducer(value: ())
                }
                    }
                }
            }
        }
    }
    
    // MARK: Delete recipe
    func deleteRecipe(_ recipe: LDRecipe) {
        self.deletingFlow(recipe)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                case .success():
                    self.recipeObserver.send(value: .success(()))
                }
            }
    }

    private func deletingFlow(_ recipe: LDRecipe) -> SignalProducer<Void, LDError> {
        return self.cloudManager.userIsLoggedIn()
            .flatMap(.concat) { [weak self] userIsLoggedIn -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                guard userIsLoggedIn else { return SignalProducer(error: .notSignedInCloud) }
                return self.cloudManager.deleteRecipeFromCloud(recipe)
            .flatMap(.concat) { [weak self] _ -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                return self.realmHelper.deleteRecipeInRealm(recipe)
            .flatMap(.concat) { [weak self] _ -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == recipe.id }) {
                    Event.shared.selectedCustomRecipes.remove(at: index)
                }
                return self.deleteRecipePictureIfNeeded(recipe.id, recipe.downloadUrl)
            .flatMap(.concat) { [weak self] _ -> SignalProducer<Void, LDError> in
                guard let self = self else { return SignalProducer(error: .genericError) }
                if recipe.isPublic {
                    return self.publicRecipeManager.deleteRecipe(recipe).mapError { _ in .genericError }
                } else {
                    return SignalProducer(value: ())
                }
                    }
                }
            }
        }
    }
    
    private func deleteRecipePictureIfNeeded(_ recipeId: String, _ downloadUrl: String?) -> SignalProducer<Void, LDError> {
        if let url = downloadUrl, !url.isEmpty {
            return self.imageHelper.deleteRecipePicOnFirebase(recipeId).mapError { _ in .genericError }
        } else {
            return SignalProducer(value: ())
        }
    }
    
    // MARK: Update recipe
    func updateRecipe() {
        self.updatingFlow()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .take(duringLifetimeOf: self)
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.isLoading.value = false
                    self.recipeObserver.send(value: .failure(error))
                case .success():
                    self.recipeObserver.send(value: .success(()))
                }
            }
    }
    
    private func updatingFlow() -> SignalProducer<Void, LDError> {
        guard informationIsValid else { return SignalProducer(error: .recipeNameMissing) }
        return self.cloudManager.userIsLoggedIn()
        .flatMap(.concat) { [weak self] userIsLoggedIn -> SignalProducer<Void, LDError> in
            guard let self = self else { return SignalProducer(error: .genericError) }
            guard userIsLoggedIn else { return SignalProducer(error: .notSignedInCloud) }
            guard let currentRecipe = self.recipe else { return SignalProducer(error: .genericError) }
            return self.saveRecipePictureIfNeeded(recipeId: currentRecipe.id)
        .flatMap(.concat) { [weak self] (downloadUrl, recipeId) -> SignalProducer<Void, LDError> in
            guard let self = self else { return SignalProducer(error: .genericError) }
            var newRecipe = self.prepareRecipe()
            newRecipe.id = currentRecipe.id
            newRecipe.downloadUrl = downloadUrl
            return self.cloudManager.updateRecipeInCloud(currentRecipe, newRecipe)
        .flatMap(.concat) { [weak self] _ -> SignalProducer<Void, LDError> in
            guard let self = self else { return SignalProducer(error: .genericError) }
            return self.realmHelper.updateRecipeInRealm(currentRecipe, newRecipe)
        .flatMap(.concat) { [weak self] _ -> SignalProducer<Void, LDError> in
            guard let self = self else { return SignalProducer(error: .genericError) }
            return (self.recipePicData.value == nil ? self.deleteRecipePictureIfNeeded(currentRecipe.id, currentRecipe.downloadUrl) : SignalProducer(value: ()))
        .flatMap(.concat) { [weak self] _ -> SignalProducer<Void, LDError> in
            guard let self = self else { return SignalProducer(error: .genericError) }
            return self.updatePublicRecipeIfNeeded(currentRecipe, newRecipe)
                        }
                    }
                }
            }
        }
    }
    
    private func updatePublicRecipeIfNeeded(_ currentRecipe: LDRecipe, _ newRecipe: LDRecipe) -> SignalProducer<Void, LDError> {
        if currentRecipe.isPublic && !newRecipe.isPublic {
            return publicRecipeManager.deleteRecipe(currentRecipe).mapError { _ in .genericError }
        } else if !currentRecipe.isPublic && newRecipe.isPublic {
            return publicRecipeManager.saveRecipe(newRecipe)
        } else if currentRecipe.isPublic && newRecipe.isPublic {
            return publicRecipeManager.updateRecipe(newRecipe)
        } else {
            return SignalProducer(value: ())
        }
    }
    
    // MARK: Temporary back-up
    @objc private func backupRecipe() {
        let recipe = LDRecipe(id: "",
                              title: self.recipeName.value,
                              servings: self.servings.value,
                              downloadUrl: self.downloadUrl.value,
                              cookingSteps: self.steps.value,
                              comments: self.comments.value,
                              ingredients: self.ingredients.value,
                              keywords: self.keywords.value,
                              isPublic: self.isPublic.value,
                              recordID: nil)
        defaults.backupRecipeData(recipe, imageData: self.recipePicData.value)
    }
    
    func ongoingRecipe() -> Bool {
        if defaults.value(forKey: Keys.recipeBackup) != nil || defaults.value(forKey: Keys.recipePicBackup) != nil {
            return true
        } else {
            return false
        }
    }
    
    func restoreRecipeData() {
        if let data = defaults.value(forKey: Keys.recipeBackup) as? Data {
            do {
                let decoder = JSONDecoder()
                let recipeData = try decoder.decode(LDRecipe.self, from: data)
                self.recipeName.value = recipeData.title
                self.servings.value = recipeData.servings
                self.downloadUrl.value = recipeData.downloadUrl
                self.steps.value = recipeData.cookingSteps
                self.comments.value = recipeData.comments
                self.ingredients.value = recipeData.ingredients
                self.keywords.value = recipeData.keywords
                self.isPublic.value = recipeData.isPublic
            } catch {
                
            }
        }
        if let imageData = defaults.value(forKey: Keys.recipePicBackup) as? Data {
            self.recipePicData.value = imageData
        }
        defaults.deleteRecipeBackup()
    }
}
