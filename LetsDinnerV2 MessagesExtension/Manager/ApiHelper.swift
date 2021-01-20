//
//  ApiHelper.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

/*
Free plan 150 Points/day
Cook plan 1500 Points/day 29$
Culinarian plan 4500 Points/day 79$
 */

import Foundation
import ReactiveSwift
import FirebaseDatabase

class ApiHelper {
    
    static let shared = ApiHelper()
    
    private init() {}
    
    private typealias ApiKey = String
    
    private func retrieveApiKey() -> SignalProducer<ApiKey, LDError> {
        return SignalProducer { observer, _ in
            Database.database().reference()
                .child(DataKeys.appInfo)
                .child(DataKeys.apiKey)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let apiKey = snapshot.value as? String else {
                        observer.send(error: .genericError)
                        return }
                    observer.send(value: apiKey)
                    observer.sendCompleted()
                }
        }
    }
    
    // Cost 1 point + 0.01 point per result returned (1.15 for 15 results)
    private func fetchRecipesIds(keyword: String, apiKey: ApiKey) -> SignalProducer<[Int], LDError> {
        return SignalProducer { observer, _ in
            var recipesIds = [Int]()
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
            let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let endpoint = String(format: "https://api.spoonacular.com/recipes/search?query=%@&number=15&apiKey=\(apiKey)", query)
            guard let endpointURL = URL(string: endpoint) else { return }
            
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "GET"
            
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 402 {
                        observer.send(error: .apiRequestLimit)
                    }
                }
                guard let dataResponse = data else {
                    if let networkError = error as NSError? {
                        if networkError.code == -1009 {
                            observer.send(error: .noNetwork)
                        }
                    }
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: dataResponse, options: .mutableLeaves) as? Dictionary<String, Any>
                    guard let hits = jsonData?["results"] as? [Dictionary <String, Any>] else { return }
                    hits.forEach { hit in
                        if let recipeId = hit["id"] as? Int {
                            recipesIds.append(recipeId)
                        }
                    }
                    observer.send(value: recipesIds)
                    observer.sendCompleted()
                } catch {
                    observer.send(error: .apiDecodingFailed)
                }
            }
            dataTask.resume()
        }
    }
    
    func loadDefaultRecipes() -> SignalProducer<[Recipe], LDError> {
        return SignalProducer { observer, _ in
            guard let path = Bundle.main.path(forResource: "SpoonacularRecipes", ofType: "json") else { return }
            var recipes = [Recipe]()
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                let json = jsonData as? [Dictionary<String, AnyObject>]
                guard let recipesInfo = json else { return }
                recipesInfo.forEach { recipe in
                    let recipe = Recipe(dict: recipe)
                    recipes.append(recipe)
                }
                observer.send(value: recipes)
                observer.sendCompleted()
            } catch {
                observer.send(error: .apiDecodingFailed)
            }
        }
    }
    
    // Cost 9.15 points for 15 results
    func fetchSearchResultsBulk(keyword: String) -> SignalProducer<[Recipe], LDError> {
        return self.retrieveApiKey()
            .flatMap(.concat) { [weak self] apiKey -> SignalProducer<[Recipe], LDError> in
                guard let self = self else { return SignalProducer(error: .genericError )}
                return self.fetchRecipesIds(keyword: keyword, apiKey: apiKey)
            .flatMap(.concat) { [weak self] recipeIds -> SignalProducer<[Recipe], LDError> in
                guard let self = self else { return SignalProducer(error: .genericError )}
                return self.fetchAPIRecipesBulk(recipeIds: recipeIds, apiKey: apiKey)
            }
        }
    }

    // Cost 1 point for first recipe then 0.5 for each recipe (8 for 15 results)
    private func fetchAPIRecipesBulk(recipeIds: [Int], apiKey: ApiKey) -> SignalProducer<[Recipe], LDError> {
        return SignalProducer { observer, _ in
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
            var recipeIdsList = ""
            recipeIds.forEach { recipeId in
                recipeIdsList += "\(recipeId),"
            }
            guard !recipeIdsList.isEmpty else {
                observer.send(value: [])
                observer.sendCompleted()
                return
            }
            recipeIdsList.remove(at: recipeIdsList.index(before: recipeIdsList.endIndex))
            let endpoint = String(format: "https://api.spoonacular.com/recipes/informationBulk?ids=\(recipeIdsList)&apiKey=\(apiKey)")
            print(endpoint)
            
            guard let endpointURL = URL(string: endpoint) else { return }
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "GET"
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 402 {
                        observer.send(error: .apiRequestLimit)
                    }
                }
                guard let dataResponse = data else {
                    if let networkError = error as NSError? {
                        if networkError.code == -1009 {
                            observer.send(error: .noNetwork)
                        }
                    }
                    return
                }
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: dataResponse, options: .mutableLeaves) as? [[String:Any]]
                    
                    guard let recipesInfo = jsonData else { return }
                    var recipes = [Recipe]()
                    recipesInfo.forEach { recipeInfo in
                        let recipe = Recipe(dict: recipeInfo)
                        recipes.append(recipe)
                    }
                    observer.send(value: recipes)
                    observer.sendCompleted()
                } catch {
                    observer.send(error: .apiDecodingFailed)
                }
            }
            dataTask.resume()
        }
    }
}
