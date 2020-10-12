//
//  ImageHelper.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 23/04/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import FirebaseStorage
import ReactiveSwift


class ImageHelper {
    
    static let shared = ImageHelper()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    func saveUserPicToFirebase(_ imageData: Data) -> SignalProducer<String, LDError> {
        return SignalProducer { observer, _ in
            let storageRef = self.storage.child(DataKeys.profilePictures).child(Event.shared.currentUser?.identifier ?? UUID().uuidString)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            storageRef.putData(imageData, metadata: metadata) { (metaData, error) in
                if error != nil {
                    observer.send(error: .profilePicUploadFail)
                }
                storageRef.downloadURL { (url, error) in
                    if error != nil {
                        observer.send(error: .profilePicUploadFail)
                    }
                    if let downloadUrl = url?.absoluteString {
                        observer.send(value: (downloadUrl))
                        observer.sendCompleted()
                    }
                }
            }
        }
    }
    
    func saveRecipePicToFirebase(_ imageData: Data, id: String) -> SignalProducer<String, LDError> {
        return SignalProducer { observer, _ in
            
            let storageRef = self.storage.child(DataKeys.recipePictures).child(id)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            storageRef.putData(imageData, metadata: metadata) { (metaData, error) in
                if error != nil {
                    observer.send(error: .recipePicUploadFail)
                }
                storageRef.downloadURL { (url, error) in
                    if error != nil {
                        observer.send(error: .recipePicUploadFail)
                    }
                    if let downloadUrl = url?.absoluteString {
                        observer.send(value: (downloadUrl))
                        observer.sendCompleted()
                    }
                }
            }
        }
    }
    
    func deleteUserPicOnFirebase() -> SignalProducer<Void, Never> {
        return SignalProducer { observer, _ in
            let reference = self.storage
                .child(DataKeys.profilePictures)
                .child(Event.shared.currentUser?.identifier ?? UUID().uuidString)
            
            reference.delete { _ in
                observer.send(value: ())
                observer.sendCompleted()
            }
        }
    }
    
    func deleteRecipePicOnFirebase(_ id: String) -> SignalProducer<Void, Never> {
        return SignalProducer { observer, _ in
            let reference = self.storage
                .child(DataKeys.recipePictures)
                .child(id)
            
            reference.delete { _ in
                observer.send(value: ())
                observer.sendCompleted()
            }
        }
    }
}
