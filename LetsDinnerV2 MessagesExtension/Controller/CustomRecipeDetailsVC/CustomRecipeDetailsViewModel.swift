//
//  CustomRecipeDetailsViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 09/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class CustomRecipeDetailsViewModel {
    
    let deleteRecipeSignal : Signal<Void, Error>
    private let deleteRecipeObserver : Signal<Void, Error>.Observer
    
    let isLoading = MutableProperty<Bool>(false)
    
    init() {
        let (deleteRecipeSignal, deleteRecipeObserver) = Signal<Void, Error>.pipe()
        self.deleteRecipeSignal = deleteRecipeSignal
        self.deleteRecipeObserver = deleteRecipeObserver
    }
    
    func deleteRecipe(_ recipe: LDRecipe) {
        if let index = Event.shared.selectedCustomRecipes.firstIndex(where: { $0.id == recipe.id }) {
            Event.shared.selectedCustomRecipes.remove(at: index)
        }
            CloudManager.shared.deleteRecipeFromCloud(recipe)
                .on(starting: { self.isLoading.value = true })
                .on(completed: { self.isLoading.value = false })
                .observe(on: UIScheduler())
                .take(duringLifetimeOf: self)
                .startWithResult { result in
                    switch result {
                    case .success():
                        self.deleteRecipeObserver.send(value: ())
                        
                    case .failure(let error):
                        self.deleteRecipeObserver.send(error: error)
                    }
            }
        }


}
