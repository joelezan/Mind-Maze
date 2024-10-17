// TriviaQuestion.swift
// Mind Maze
//
// Created by Joel Ezan on 10/11/24.

import Foundation

struct TriviaResponse: Decodable {
   let results: [TriviaResult]
}

struct TriviaResult: Decodable {
   let question: String
   let correctAnswer: String
   let incorrectAnswers: [String]

   private enum CodingKeys: String, CodingKey {
       case question
       case correctAnswer = "correct_answer"
       case incorrectAnswers = "incorrect_answers"
   }
}

struct TriviaQuestion {
   let question: String
   let answers: [String]
   let correctAnswer: String
}
