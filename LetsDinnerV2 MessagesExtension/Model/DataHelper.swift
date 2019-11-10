//
//  DataHelper.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

class DataHelper {
    
    static let shared = DataHelper()
    
    private init() {}
    
    func loadPredefinedRecipes(completion: @escaping (_ recipes: [Recipe]) -> Void) {
        var recipes = [Recipe]()
        guard let path = Bundle.main.path(forResource: "PredefinedRecipes", ofType: "json") else { return }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            guard let json = jsonData as? Dictionary<String, AnyObject> else { return }
            guard let hits = json["hits"] as? [Dictionary<String, Any>] else { return }
            
            hits.forEach({ recipe in
                let newRecipe = Recipe(dict: recipe)
                recipes.append(newRecipe)
            })
            DispatchQueue.main.async {
                completion(recipes)
            }
        } catch let error {
            print("JSON decoding failed", error)
        }
    }
    
    func loadSearchedRecipes(keyword: String, display: (Bool) -> Void, completion: @escaping (_ recipes: [Recipe]) -> Void) {
        var recipes = [Recipe]()
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let endpoint = String(format:
        "https://api.edamam.com/search?q=%@&app_id=\(ApiKeys.appId)&app_key=\(ApiKeys.apiKey)",query)
        guard let endpointURL = URL(string: endpoint) else {
            print("invalid URL")
            return
        }
        display(true)
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "GET"
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data else {
                print("Invalid payload")
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: dataResponse, options: .mutableLeaves) as? Dictionary<String, Any>
                guard let hits = jsonData?["hits"] as? [Dictionary <String, Any>] else { return }
                hits.forEach { recipe in
                    let newRecipe = Recipe(dict: recipe)
                    recipes.append(newRecipe)
                }
                DispatchQueue.main.async {
                    completion(recipes)
                }
            } catch let error {
                print("JSON decoding failed", error)
            }
        }
        dataTask.resume()
        
    }
    
   
    
    
    
}
