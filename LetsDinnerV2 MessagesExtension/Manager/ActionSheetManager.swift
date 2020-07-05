//
//  ActionSheetManager.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 1/7/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class ActionSheetManager {
    
    typealias ActionCompletion = ((UIAlertAction?) -> Void)

    init() {}
        
    let cancelAction = UIAlertAction(title: AlertStrings.cancel, style: .cancel, handler: nil)
    
    // MARK: Edit Image ActionSheet
    func presentEditImageActionSheet (sourceView: UIView,
                                                changeActionCompletion: @escaping ActionCompletion,
                                                deleteActionCompletion: @escaping ActionCompletion) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: AlertStrings.changeImageActionSheetMessage, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.bounds
        let change = UIAlertAction(title: AlertStrings.change, style: .default) { _ in
            changeActionCompletion(nil)
        }
        let delete = UIAlertAction(title: AlertStrings.delete, style: .destructive) { _ in
            deleteActionCompletion(nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(change)
        alert.addAction(delete)
        return alert
    }
    
    // MARK: EditMode ActionSheet
    func presentEditActionSheet(sourceView: UIView,
                                                  message: String,
                                                  editActionCompletion: @escaping ActionCompletion,
                                                  deleteActionCompletion: @escaping ActionCompletion) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.bounds
        
        let editAction = UIAlertAction(title: AlertStrings.editAction, style: .default) { _ in
            editActionCompletion(nil)
        }
        let deleteAction = UIAlertAction(title: AlertStrings.delete, style: .destructive) { _ in
            deleteActionCompletion(nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        return alert
    }
    
    // MARK: Done/Save ActionSheet
    func presentDoneActionSheet(sourceView: UIView,
                                  message: String,
                                  saveActionCompletion: @escaping ActionCompletion,
                                  discardActionCompletion: @escaping ActionCompletion) -> UIAlertController {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.bounds

        let saveAction = UIAlertAction(title: AlertStrings.save, style: .default) { _ in
            saveActionCompletion(nil)
        }
        let discardAction = UIAlertAction(title: AlertStrings.discard, style: .destructive) { _ in
            discardActionCompletion(nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        alert.addAction(discardAction)
        return alert
    }
    
}
