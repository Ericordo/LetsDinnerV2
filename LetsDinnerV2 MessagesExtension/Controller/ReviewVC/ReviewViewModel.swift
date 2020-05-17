//
//  ReviewViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class ReviewViewModel {
    
    let isLoading = MutableProperty<Bool>(false)
    
    let dataUploadSignal: Signal<Void, LDError>
    private let dataUploadObserver: Signal<Void, LDError>.Observer

    init() {
        let (dataUploadSignal, dataUploadObserver) = Signal<Void, LDError>.pipe()
        self.dataUploadSignal = dataUploadSignal
        self.dataUploadObserver = dataUploadObserver
    }
    
    func uploadEvent() {
        Event.shared.uploadEvent()
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .observe(on: UIScheduler())
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.dataUploadObserver.send(error: error)
                case .success():
                    self.dataUploadObserver.send(value: ())
                }
        }
    }
}
