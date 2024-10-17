// QuestionView.swift
// Mind Maze
//
// Created by Joel Ezan on 10/12/24.

import SwiftUI

struct QuestionView: View {
    let question: TriviaQuestion
    @Binding var selectedAnswer: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Question Text
            Text(decodeHTML(question.question))  // Decode HTML entities
                .font(.headline)
                .padding(.bottom, 10)

            // Display the possible answers in large boxes
            ForEach(question.answers, id: \.self) { answer in
                Button(action: {
                    // Set selected answer for this question
                    selectedAnswer = answer
                }) {
                    HStack {
                        // Show checkmark if this answer is selected
                        if selectedAnswer == answer {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }

                        // Answer Text
                        Text(decodeHTML(answer))  // Decode HTML entities for answers
                            .frame(maxWidth: .infinity) // Full width of the screen
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                .buttonStyle(PlainButtonStyle()) // Disable the button style animation
            }
        }
        .padding(.horizontal)
        .onAppear {
            // Log the decoded question text
            print("Question: \(decodeHTML(question.question))")  // Debugging statement
            
            // Log each decoded answer text
            for answer in question.answers {
                print("Answer: \(decodeHTML(answer))")  // Debugging statement
            }
        }
    }
    
    // Function to decode HTML entities
    func decodeHTML(_ text: String) -> String {
        var decodedString = text
        
        // Replace known HTML entities with their corresponding characters
        decodedString = decodedString
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&eacute;", with: "é")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")

        return decodedString
    }
}

// Preview
#Preview {
    QuestionView(
        question: TriviaQuestion(question: "What was the name of Captain Nemo&#039;s submarine in &quot;20,000 Leagues Under the Sea&quot;?", answers: ["The Atlantis", "The Poseidon", "The Neptune", "The Nautilus"], correctAnswer: "The Nautilus"),
        selectedAnswer: .constant(nil)
    )
}
