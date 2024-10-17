//  CategoryResponse.swift
//  Mind Maze
//
//  Created by Joel Ezan on 10/12/24.
//

import Foundation

struct CategoryResponse: Decodable {
    let triviaCategories: [TriviaCategory]

    enum CodingKeys: String, CodingKey {
        case triviaCategories = "trivia_categories"
    }
}

struct TriviaCategory: Decodable {
    let id: Int
    let name: String
}
