//
//  DataHelper - Spoonacular.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

class DataHelper {
    
    static let shared = DataHelper()
    
    private init() {}
    
    func getSearchedRecipesIds(keyword: String, display: (Bool) -> Void, completion: @escaping (Result<[Int], ApiError>) -> Void) {
        var recipesIds = [Int]()
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let endpoint = String(format: "https://api.spoonacular.com/recipes/search?query=%@&number=15&apiKey=\(ApiKeys.backUpKey)", query)
        guard let endpointURL = URL(string: endpoint) else {
            print("invalid URL")
            return
        }
        display(true)
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "GET"
    
        let dataTask = session.dataTask(with: request) { (data, response, error) in

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 402 {
                    DispatchQueue.main.async {
                        completion(.failure(ApiError.requestLimit))
                    }
                }
            }
            
            guard let dataResponse = data else {
                print("Invalid payload")
                
                if let networkError = error as NSError? {
                    if networkError.code == -1009 {
                        DispatchQueue.main.async {
                            completion(.failure(ApiError.noNetwork))
                        }
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
                        print(recipeId)
                    }
                    
                }
                DispatchQueue.main.async {
                    completion(.success(recipesIds))
                }
            } catch {
                print("JSON decoding failed", error, error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(ApiError.decodingFailed))
                }
            }
        }
        dataTask.resume()
    }


    func loadSearchResults(recipeId: Int, display: (Bool) -> Void, completion: @escaping (Result<Recipe, ApiError>) -> Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        let endpoint = String(format: "https://api.spoonacular.com/recipes/\(recipeId)/information?includeNutrition=false&apiKey=\(ApiKeys.backUpKey)")
        guard let endpointURL = URL(string: endpoint) else {
            print("invalid URL")
            return
        }
        display(true)
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "GET"
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 402 {
                    DispatchQueue.main.async {
                        completion(.failure(ApiError.requestLimit))
                    }
                }
            }
            guard let dataResponse = data else {
                print("Invalid payload")
                
                if let networkError = error as NSError? {
                    if networkError.code == -1009 {
                        DispatchQueue.main.async {
                            completion(.failure(ApiError.noNetwork))
                        }
                    }
                }
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: dataResponse, options: .mutableLeaves) as? Dictionary<String, Any>
                
                
                guard let recipeInfo = jsonData else { return }
                let recipe = Recipe(dict: recipeInfo)
                
                DispatchQueue.main.async {
                    completion(.success(recipe))
                }
            } catch {
                print("JSON decoding failed", error, error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(ApiError.decodingFailed))
                }
            }
        }
        dataTask.resume()
    }
    
    
    func loadPredefinedRecipes(completion: @escaping (_ recipes: [Recipe]) -> Void) {
     
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
            
            DispatchQueue.main.async {
                completion(recipes)
            }
        } catch let error {
            print("JSON decoding failed", error)
        }
    }
    
    
}
