//
//  DataHelper - Spoonacular.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class DataHelper {
    
    static let shared = DataHelper()
    
    private init() {}
    
    private func fetchRecipesIds(keyword: String) -> SignalProducer<[Int],ApiError> {
        return SignalProducer { observer, disposable in
            var recipesIds = [Int]()
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
            let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let endpoint = String(format: "https://api.spoonacular.com/recipes/search?query=%@&number=15&apiKey=\(ApiKeys.apiKeySpoonacular)", query)
            guard let endpointURL = URL(string: endpoint) else { return }
            
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "GET"
            
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 402 {
                        observer.send(error: .requestLimit)
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
                    print(recipesIds)
                    observer.send(value: recipesIds)
                    observer.sendCompleted()
                } catch {
                    observer.send(error: .decodingFailed)
                }
            }
            dataTask.resume()
        }
    }
    
    private func loadSearchResults(recipeId: Int, completion: @escaping (Result<Recipe, ApiError>) -> Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        let endpoint = String(format: "https://api.spoonacular.com/recipes/\(recipeId)/information?includeNutrition=false&apiKey=\(ApiKeys.apiKeySpoonacular)")
        guard let endpointURL = URL(string: endpoint) else {
            print("invalid URL")
            return
        }
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "GET"
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 402 {
                        completion(.failure(ApiError.requestLimit))
                }
            }
            guard let dataResponse = data else {
                print("Invalid payload")

                if let networkError = error as NSError? {
                    if networkError.code == -1009 {
                            completion(.failure(ApiError.noNetwork))
                    }
                }
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: dataResponse, options: .mutableLeaves) as? Dictionary<String, Any>


                guard let recipeInfo = jsonData else { return }
                let recipe = Recipe(dict: recipeInfo)

                    completion(.success(recipe))
            } catch {
                print("JSON decoding failed", error, error.localizedDescription)
                    completion(.failure(ApiError.decodingFailed))
            }
        }
        dataTask.resume()
    }
    
// To reactive later to be fully reactive
//    private func fetchAPIRecipe(recipeId: Int) -> SignalProducer<Recipe, ApiError> {
//        return SignalProducer { observer, disposable in
//            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
//            let endpoint = String(format: "https://api.spoonacular.com/recipes/\(recipeId)/information?includeNutrition=false&apiKey=\(ApiKeys.apiKeySpoonacular)")
//            guard let endpointURL = URL(string: endpoint) else { return }
//            var request = URLRequest(url: endpointURL)
//            request.httpMethod = "GET"
//            let dataTask = session.dataTask(with: request) { (data, response, error) in
//                if let httpResponse = response as? HTTPURLResponse {
//                    if httpResponse.statusCode == 402 {
//                        observer.send(error: .requestLimit)
//                    }
//                }
//                guard let dataResponse = data else {
//                    if let networkError = error as NSError? {
//                        if networkError.code == -1009 {
//                            observer.send(error: .noNetwork)
//                        }
//                    }
//                    return
//                }
//                do {
//                    let jsonData = try JSONSerialization.jsonObject(with: dataResponse, options: .mutableLeaves) as? Dictionary<String, Any>
//                    guard let recipeInfo = jsonData else { return }
//                    let recipe = Recipe(dict: recipeInfo)
//
//                    observer.send(value: recipe)
//                    observer.sendCompleted()
//                } catch {
//                    observer.send(error: .decodingFailed)
//                }
//            }
//            dataTask.resume()
//        }
//    }
    
    private func fetchAPIRecipes(recipeIds: [Int]) -> SignalProducer<[Recipe], ApiError> {
        let dispatchGroup = DispatchGroup()
        var recipes = [Recipe]()
        return SignalProducer { observer, disposable in
            recipeIds.forEach { recipeId in
                dispatchGroup.enter()
                self.loadSearchResults(recipeId: recipeId) { result in
                    switch result {
                    case .failure(let error):
                        observer.send(error: error)
                    case .success(let recipe):
                        recipes.append(recipe)
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                observer.send(value: recipes)
                observer.sendCompleted()
            }
        }
    }
    
    func loadDefaultRecipes() -> SignalProducer<[Recipe], ApiError> {
        return SignalProducer { observer, disposable in
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
                observer.send(error: .decodingFailed)
            }
        }
    }
        
    func fetchSearchResults(keyword: String) -> SignalProducer<[Recipe], ApiError> {
        return self.fetchRecipesIds(keyword: keyword).flatMap(.latest) { (recipeIds) -> SignalProducer<[Recipe], ApiError> in
            return self.fetchAPIRecipes(recipeIds: recipeIds)
        }
            }
}
