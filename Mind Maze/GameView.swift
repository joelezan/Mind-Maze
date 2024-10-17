// GameView.swift
// Mind Maze
//
// Created by Joel Ezan on 10/12/24.

import SwiftUI

struct GameView: View {
    let questionCount: Int
    let timerDuration: Int // Duration selected by the user in seconds
    let type: String // Type of questions selected
    let category: Int? // Selected category ID
    @State private var remainingTime: Int // To keep track of the remaining time
    @State private var timer: Timer? // Timer object
    
    // Track selected answers for each question
    @State private var selectedAnswers: [String?] // Array to hold selected answers
    @State private var score: Int = 0 // Variable to track the score
    @State private var showAlert: Bool = false // Variable to control alert visibility

    @State private var questions: [TriviaQuestion] = [] // Store fetched questions
    @State private var incorrectQuestions: [(question: String, correctAnswer: String)] = [] // Track incorrect questions and answers

    init(questionCount: Int, timerDuration: Int, type: String, category: Int?) {
        self.questionCount = questionCount
        self.timerDuration = timerDuration
        self.type = type
        self.category = category
        self._remainingTime = State(initialValue: timerDuration) // Set initial remaining time
        self._selectedAnswers = State(initialValue: Array(repeating: nil, count: questionCount)) // Initialize selected answers
    }

    var body: some View {
        VStack {
            // Timer Display
            Text("Time remaining: \(remainingTime)s")
                .font(.largeTitle)
                .padding()

            // Scrollable view for questions
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<questionCount, id: \.self) { index in
                        if index < questions.count {
                            QuestionView(
                                question: questions[index], // Display fetched questions
                                selectedAnswer: $selectedAnswers[index] // Pass binding for selected answer
                            )
                            .padding(.vertical)
                            Divider() // Line separator between questions
                        }
                    }
                }
            }

            // Submit Button
            Button(action: {
                calculateScore() // Calculate score when the button is tapped
                showAlert = true // Show alert
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity) // Full width of the button
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .alert(isPresented: $showAlert) {
                let incorrectList = incorrectQuestions.map { "\($0.question) - Correct Answer: \($0.correctAnswer)" }.joined(separator: "\n")
                return Alert(
                    title: Text("Score"),
                    message: Text("You scored \(score) out of \(questionCount)\n\nIncorrect Questions:\n\(incorrectList)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            startTimer() // Start the timer when the view appears
            Task {
                await fetchQuestions() // Fetch questions when the view appears
            }
        }
        .onDisappear {
            timer?.invalidate() // Invalidate the timer when the view disappears
        }
    }

    // Start the timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate() // Stop the timer when it reaches zero
                calculateScore() // Calculate score when time expires
                showAlert = true // Show alert with results
            }
        }
    }

    // Fetch questions based on selected type and category
    private func fetchQuestions() async {
        var urlString = "https://opentdb.com/api.php?amount=\(questionCount)"
        if let category = category {
            urlString += "&category=\(category)"
        }
        if type != "Any Type" {
            urlString += "&type=\(type)"
        }

        guard let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let triviaResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
            DispatchQueue.main.async {
                questions = triviaResponse.results.map { result in
                    TriviaQuestion(
                        question: result.question,
                        answers: result.incorrectAnswers + [result.correctAnswer].shuffled(), // Shuffle answers
                        correctAnswer: result.correctAnswer
                    )
                }
            }
        } catch {
            print("Error fetching questions: \(error)")
        }
    }

    // Calculate the score based on selected answers
    private func calculateScore() {
        score = 0
        incorrectQuestions = [] // Reset incorrect questions list

        for (index, answer) in selectedAnswers.enumerated() {
            if answer == questions[index].correctAnswer {
                score += 1
            } else {
                // Add the incorrect question and correct answer to the list
                incorrectQuestions.append((questions[index].question, questions[index].correctAnswer))
            }
        }
    }
}

// Preview
#Preview {
    GameView(questionCount: 2, timerDuration: 60, type: "multiple", category: nil)
}
