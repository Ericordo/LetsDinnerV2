//
//  RealmHelper.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
    
    static let shared = RealmHelper()
    
    private let realm = try! Realm()
    
    private init() {}
    
    func loadCustomRecipes() -> Results<CustomRecipe>? {
        return realm.objects(CustomRecipe.self)
    }
    
    
}
