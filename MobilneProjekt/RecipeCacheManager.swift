//
//  RecipeCacheManager.swift
//  MobilneProjekt
//
//  Created by Artur Balcer on 21/12/2023.
//

import Foundation

class RecipeCacheManager {
    static let shared = RecipeCacheManager()

    private init() {}

    func saveRecipes(_ recipes: [Recipe]) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(recipes)
            UserDefaults.standard.set(encodedData, forKey: "cachedRecipes")
        } catch {
            print("Error encoding recipes: \(error)")
        }
    }

    func loadRecipes() -> [Recipe]? {
        guard let savedData = UserDefaults.standard.data(forKey: "cachedRecipes") else { return nil }

        do {
            let decoder = JSONDecoder()
            let recipes = try decoder.decode([Recipe].self, from: savedData)
            return recipes
        } catch {
            print("Error decoding recipes: \(error)")
            return nil
        }
    }
}
