//  ContentView.swift
//  Mind Maze
//
//  Created by Joel Ezan on 10/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var questionCount: Int = 2
    @State var category: String = "Any Category"
    @State var difficulty: String = "Easy"
    @State var type: String = "Any Type"
    @State var duration: Int = 60
    @State private var categories: [TriviaCategory] = []
    @State private var selectedCategoryId: Int? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 300, height: 55)
                        .overlay(
                            TextField("Enter number of questions", text: Binding(
                                get: { String(questionCount) },
                                set: {
                                    if let value = Int($0), value >= 0 {
                                        questionCount = value
                                    }
                                }
                            ))
                            .keyboardType(.numberPad)
                            .foregroundColor(.black)
                            .padding(.leading)
                        )

                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 300, height: 55)
                        .overlay(
                            HStack {
                                Text("Select Category")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                                if categories.isEmpty {
                                    Text("Loading...")
                                } else {
                                    Picker(selection: $selectedCategoryId, label: Text("")) {
                                        Text("Any Category").tag(nil as Int?)
                                        ForEach(categories, id: \.id) { category in
                                            Text(category.name).tag(category.id as Int?)
                                        }
                                    }
                                    .foregroundColor(.black)
                                    .pickerStyle(MenuPickerStyle())
                                }
                            }
                            .padding()
                        )

                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 300, height: 55)
                        .overlay(
                            VStack {
                                HStack {
                                    Text("Difficulty:")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Text(difficulty)
                                        .foregroundColor(.black)
                                    Slider(value: Binding(
                                        get: {
                                            difficulty == "Easy" ? 0 : (difficulty == "Medium" ? 1 : 2)
                                        },
                                        set: { newValue in
                                            let index = Int(newValue.rounded())
                                            difficulty = index == 0 ? "Easy" : (index == 1 ? "Medium" : "Hard")
                                        }), in: 0...2, step: 1)
                                }
                            }
                            .padding(.horizontal)
                        )

                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 300, height: 55)
                        .overlay(
                            HStack {
                                Text("Select Type:")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                                Picker(selection: $type, label: Text("")) {
                                    Text("Any Type").tag("Any Type")
                                    Text("Multiple Choice").tag("multiple")
                                    Text("True or False").tag("boolean")
                                }
                                .foregroundColor(.black)
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding()
                        )

                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 300, height: 55)
                        .overlay(
                            HStack {
                                Text("Timer Duration:")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                                Picker(selection: $duration, label: Text("")) {
                                    Text("30 seconds").tag(30)
                                    Text("60 seconds").tag(60)
                                    Text("120 seconds").tag(120)
                                    Text("300 seconds").tag(300)
                                    Text("1 hour").tag(3600)
                                }
                                .foregroundColor(.black)
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding()
                        )

                    Spacer()

                    NavigationLink(destination: GameView(questionCount: questionCount, timerDuration: duration, type: type, category: selectedCategoryId)) {
                        Text("Start Trivia")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300, height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.green)
                            )
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Trivia Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
        .task {
            await fetchTriviaData()
        }
    }

    private func fetchTriviaData() async {
        let url = URL(string: "https://opentdb.com/api_category.php")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(CategoryResponse.self, from: data)
            DispatchQueue.main.async {
                categories = response.triviaCategories
            }
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
}

// Preview
#Preview {
    ContentView()
}
