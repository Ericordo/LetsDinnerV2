//
//  RegistrationViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 17/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class RegistrationViewModel {
    
    let firstName : MutableProperty<String>
    let lastName : MutableProperty<String>
    let address : MutableProperty<String>
    let profilePicData: MutableProperty<Data?>
    let profilePicUrl : MutableProperty<String?>
    let isLoading = MutableProperty<Bool>(false)
    
    let dataUploadSignal: Signal<Void, LDError>
    private let dataUploadObserver: Signal<Void, LDError>.Observer
    
    let doneActionSignal : Signal<Void, Never>
    private let doneActionObserver : Signal<Void, Never>.Observer
    
    private let initialFirstName : String
    private let initialLastName : String
    private let initialAddress : String
    let initialUrl : String
    
    init() {
        let usernameArray = defaults.username.split(separator: " ")
        firstName = MutableProperty(String(usernameArray.first ?? ""))
        lastName = MutableProperty(String(usernameArray.last ?? ""))
        address = MutableProperty(defaults.address)
        profilePicData = MutableProperty(nil)
        profilePicUrl = MutableProperty(defaults.profilePicUrl)
        
        let (dataUploadSignal, dataUploadObserver) = Signal<Void, LDError>.pipe()
        self.dataUploadSignal = dataUploadSignal
        self.dataUploadObserver = dataUploadObserver
        
        let (doneActionSignal, doneActionObserver) = Signal<Void, Never>.pipe()
        self.doneActionSignal = doneActionSignal
        self.doneActionObserver = doneActionObserver
        
        initialFirstName = String(usernameArray.first ?? "")
        initialLastName = String(usernameArray.last ?? "")
        initialAddress = defaults.address
        initialUrl = defaults.profilePicUrl
    }
    
    func infoIsValid() -> Bool {
        if self.firstName.value.isEmpty || self.lastName.value.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func didTapDone() {
        if initialAddress == address.value &&
            initialUrl == profilePicUrl.value &&
            initialFirstName == firstName.value &&
            initialLastName == lastName.value {
            if initialUrl.isEmpty && self.profilePicData.value != nil ||
                !initialUrl.isEmpty && self.profilePicData.value == nil {
                self.doneActionObserver.send(value: ())
            } else {
                self.dataUploadObserver.send(value: ())
            }
        } else {
            self.doneActionObserver.send(value: ())
        }
    }
    
    func saveUserInformation() {
        defaults.address = address.value
        CloudManager.shared.saveUserInfoOnCloud(address.value, key: Keys.address)
        let username = firstName.value.capitalized + " " + lastName.value.capitalized
        defaults.username = username
        CloudManager.shared.saveUserInfoOnCloud(username, key: Keys.username)
        if let data = profilePicData.value {
            self.saveProfilePicture(data)
        } else {
            if !defaults.profilePicUrl.isEmpty {
                ImageHelper.shared.deleteUserPicOnFirebase()
            }
            self.updateProfilePicUrl("")
            self.dataUploadObserver.send(value: ())
        }
    }
    
    private func saveProfilePicture(_ imageData: Data) {
        ImageHelper.shared.saveUserPicToFirebase(imageData)
            .on(starting: { self.isLoading.value = true })
            .on(completed: { self.isLoading.value = false })
            .observe(on: UIScheduler())
            .startWithResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.dataUploadObserver.send(error: error)
                case .success(let url):
                    self.updateProfilePicUrl(url)
                    self.dataUploadObserver.send(value: ())
                }
        }
    }
    
    private func updateProfilePicUrl(_ url: String) {
        Event.shared.currentUser?.profilePicUrl = url
        defaults.profilePicUrl = url
        CloudManager.shared.saveUserInfoOnCloud(url, key: Keys.profilePicUrl)
    }
}


