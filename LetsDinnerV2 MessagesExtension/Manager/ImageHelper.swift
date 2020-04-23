//
//  ImageHelper.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 23/04/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import FirebaseStorage


class ImageHelper {
    
    static let shared = ImageHelper()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    func saveUserPicToFirebase(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        
        let storageRef = storage.child(DataKeys.profilePictures).child(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)
        
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
    func deleteUserPicOnFirebase() {}
    func updateUserPicOnFirebase() {}
}
