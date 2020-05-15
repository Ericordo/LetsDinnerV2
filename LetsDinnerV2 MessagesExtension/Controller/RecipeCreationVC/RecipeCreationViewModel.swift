//
//  RecipeCreationViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 09/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class RecipeCreationViewModel {
    
    let recipeUploadSignal : Signal<Void, Error>
    private let recipeUploadObserver : Signal<Void, Error>.Observer
    
    let recipeUpdateSignal : Signal<Void, Error>
    private let recipeUpdateObserver : Signal<Void, Error>.Observer
    
    let isLoading = MutableProperty<Bool>(false)
    
    init() {
        let (recipeUploadSignal, recipeUploadObserver) = Signal<Void, Error>.pipe()
        self.recipeUploadSignal = recipeUploadSignal
        self.recipeUploadObserver = recipeUploadObserver
        
        let (recipeUpdateSignal, recipeUpdateObserver) = Signal<Void, Error>.pipe()
        self.recipeUpdateSignal = recipeUpdateSignal
        self.recipeUpdateObserver = recipeUpdateObserver
    }
    
    func saveRecipe(_ recipe: LDRecipe) {
        CloudManager.shared.saveRecipeAndIngredientsOnCloud(recipe)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithResult { result in
                switch result {
                case .success():
                    self.recipeUploadObserver.send(value: ())
                case .failure(let error):
                    self.recipeUploadObserver.send(error: error)
                }
        }
    }
    
    func updateRecipe(currentRecipe: LDRecipe, newRecipe: LDRecipe) {
        CloudManager.shared.updateRecipeInCloud(currentRecipe, newRecipe)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithResult { result in
                switch result {
                case .success():
                    self.recipeUpdateObserver.send(value: ())
                case .failure(let error):
                    self.recipeUpdateObserver.send(error: error)
                }
        }
        
    }
    
    
}