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
                storageRef.downloadURL { (url, error ) in
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
    
    func saveRecipePicToFirebase(_ image: UIImage, id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
                
        let storageRef = storage.child(DataKeys.recipePictures).child(id)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metadata) { (metaData, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
            }
            storageRef.downloadURL { (url, error ) in
                if error != nil {
                    DispatchQueue.main.async {
                        completion(.failure(error!))
                    }
                }
                if let downloadUrl = url?.absoluteString {
                    DispatchQueue.main.async {
                        completion(.success(downloadUrl))
                    }
                    
                }
            }
        }
    }
    
    #warning("To implement")
    func deleteUserPicOnFirebase() {
        let reference = storage.child(DataKeys.profilePictures).child(Event.shared.currentUser?.identifier ?? UUID().uuidString)
        
        reference.delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateUserPicOnFirebase() {}
}
