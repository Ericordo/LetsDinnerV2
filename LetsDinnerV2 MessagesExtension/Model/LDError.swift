//
//  LDError.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

enum LDError : Error {
    case genericError
    case noUserIdentifier
    case eventUploadFail
    case eventFetchingFail
    case profilePicUploadFail
    case recipeSaveRealmFail
    case transferToRealmFail
    case recipeUpdateRealmFail
    case recipeDeleteRealmFail
    // TODO: Use the following two errors
    case addToCalendarFail
    case addToRemindersFail
    case calendarDenied
    case remindersDenied
    case statusUpdateFail
    case taskUpdateFail
    case rescheduleFail
    case recipeNameMissing
    case recipeSaveCloudFail
    case recipePicUploadFail
    case recipeUpdateCloudFail
    case recipeDeleteCloudFail
    case recipeFetchCloudFail
    case notSignedInCloud
    case notSignedInCloudLoadingRecipes
    case apiRequestLimit
    case noNetwork
    case apiDecodingFailed
    case publicRecipeUploadFail
    case publicRecipeUpdateFail
}

extension LDError {
    var description : String {
        switch self {
        case .genericError, .noUserIdentifier:
            return AlertStrings.genericError
        case .eventUploadFail:
            return AlertStrings.eventUploadFail
        case .eventFetchingFail:
            return AlertStrings.eventFetchingFail
        case .profilePicUploadFail:
            return AlertStrings.profilePicUploadError
        case .recipeSaveRealmFail:
            return AlertStrings.recipeSaveRealmError
        case .transferToRealmFail:
            return AlertStrings.transferToRealmError
        case .recipeUpdateRealmFail:
            return AlertStrings.recipeUpdateRealmError
        case .recipeDeleteRealmFail:
            return AlertStrings.recipeDeleteRealmError
        case .addToCalendarFail:
            return AlertStrings.addToCalendarError
        case .addToRemindersFail:
            return AlertStrings.addToRemindersError
        case .calendarDenied:
            return AlertStrings.calendarDenied
        case .remindersDenied:
            return AlertStrings.remindersDenied
        case .statusUpdateFail:
            return AlertStrings.statusUpdateError
        case .taskUpdateFail:
            return AlertStrings.taskUpdateFail
        case .rescheduleFail:
            return AlertStrings.rescheduleFail
        case .recipeNameMissing:
            return AlertStrings.recipeNameMissing
        case .recipeSaveCloudFail:
            return AlertStrings.recipeSaveCloudError
        case .recipePicUploadFail:
            return AlertStrings.saveImageErrorMessage
        case .recipeUpdateCloudFail:
            return AlertStrings.recipeUpdateCloudError
        case .recipeDeleteCloudFail:
            return AlertStrings.recipeDeleteCloudError
        case .recipeFetchCloudFail:
            return AlertStrings.recipeFetchCloudError
        case .notSignedInCloud:
            return AlertStrings.notSignedInCloudError
        case .notSignedInCloudLoadingRecipes:
            return AlertStrings.notSignedInCloudLoadingRecipesError
        case .apiRequestLimit:
            return AlertStrings.requestLimit
        case .noNetwork:
            return AlertStrings.noNetwork
        case .apiDecodingFailed:
            return AlertStrings.decodingFailed
        case .publicRecipeUploadFail:
            return AlertStrings.publicRecipeUploadFail
        case .publicRecipeUpdateFail:
            return AlertStrings.publicRecipeUpdateFail
        }
    }
}
