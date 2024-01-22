// Recipe.swift
import Foundation

struct Recipe: Codable {
    let _id: String
    let author: String
    let name: String
    let cookingTime: Int
    let userId: String
    let imageUrl: String?
    let servings: Int
    let ingredients: [String]
    let description: String
    let instructions: String

    enum CodingKeys: String, CodingKey {
        case _id
        case author
        case name
        case cookingTime
        case userId
        case imageUrl
        case servings
        case ingredients
        case description
        case instructions
    }
}

struct RecipeResponse: Decodable {
    let count: Int
    let recipes: [Recipe]
}
