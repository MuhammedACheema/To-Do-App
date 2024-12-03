import SwiftUI
import GoogleGenerativeAI

struct ContentView: View {
    private var timer = PomodoroTimer(workInSeconds: 10, breakInSeconds: 5)
    
    @State private var displayWarning = false
    @Environment(\.scenePhase) var scenePhase
    @State private var todoItems: [TodoItem] = [] // List of to-do items
    @State private var newTodo: String = "" // New to-do input field
    @State private var goals: [String] = [] // Goals from GoalSettingView
    @State private var path: [String] = [] // Navigation path
    
    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    @State var textInput = ""
    @State var aiResponse = "Yurrr"
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                // Fetch and display the AI response
                Button(action: prioritizeTodos) {
                    Text("Prioritize To-Do Items")
                }
                
                if !todoItems.isEmpty {
                    VStack {
                        // To-Do List title
                        Text("Prioritized To-Do List")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                        
                        // Display prioritized list
                        List {
                            ForEach(todoItems) { item in
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.headline)
                                    Text("Category: \(item.category)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding()
                }
                
                // Input field and add button
                HStack {
                    TextField("New Task", text: $newTodo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        if !newTodo.isEmpty {
                            todoItems.append(TodoItem(id: UUID(), title: newTodo, category: "General"))
                            newTodo = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                .padding()
                
                // Pomodoro Timer
                CircularTimer(fraction: timer.fractionPassed, primaryText: timer.secondsLeftString, secondaryText: timer.mode.rawValue)
                
                HStack {
                    // Timer control buttons
                    if timer.state == .idle {
                        CircleButton(icon: "play.fill") {
                            timer.start()
                        }
                    }
                    if timer.state == .paused {
                        CircleButton(icon: "play.fill") {
                            timer.resume()
                        }
                    }
                    if timer.state == .running {
                        CircleButton(icon: "pause.fill") {
                            timer.pause()
                        }
                    }
                    if timer.state == .running || timer.state == .paused {
                        CircleButton(icon: "stop.fill") {
                            timer.reset()
                        }
                    }
                }
                
                // Notification Disabled Warning
                if displayWarning {
                    NotificationDisabled()
                }
                
                Spacer()
                
                // Navigation Buttons
                HStack {
                    Button("Goals") {
                        path.append("Goals")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("To-Do List") {
                        path.append("TodoList")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RadialGradient(
                    gradient: Gradient(colors: [Color("Light"), Color("Dark")]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 500
                )
            )
            .onAppear(perform: fetchGoals)
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    Notification.checkAuthorization { authorized in
                        displayWarning = !authorized
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "Goals" {
                    GoalSettingView()
                } else if destination == "TodoList" {
                    TodoListView()
                }
            }
        }
    }
    
    // Fetch goals from GoalSettingView
    private func fetchGoals() {
        goals = [
            UserDefaults.standard.string(forKey: "yearlyGoal") ?? "",
            UserDefaults.standard.string(forKey: "monthlyGoal") ?? "",
            UserDefaults.standard.string(forKey: "weeklyGoal") ?? "",
            UserDefaults.standard.string(forKey: "dailyGoal") ?? ""
        ].filter { !$0.isEmpty }
    }
    
    // Use AI to prioritize the To-Do items
    private func prioritizeTodos() {
        aiResponse = "Prioritizing tasks..."
        Task {
            do {
                let toDoList = todoItems.map { $0.title }.joined(separator: ", ")
                let goalsList = goals.joined(separator: ", ")
                let prompt = "Given these tasks: \(toDoList) and these goals: \(goalsList), prioritize the tasks based on their relevance to achieving the goals."
                
                let response = try await model.generateContent(prompt)
                
                guard let responseText = response.text else {
                    aiResponse = "Could not generate priorities."
                    return
                }
                
                // Parse AI response to reorder tasks
                let prioritizedTitles = responseText.components(separatedBy: ", ")
                todoItems.sort { item1, item2 in
                    let index1 = prioritizedTitles.firstIndex(of: item1.title) ?? prioritizedTitles.count
                    let index2 = prioritizedTitles.firstIndex(of: item2.title) ?? prioritizedTitles.count
                    return index1 < index2
                }
                
                aiResponse = "Tasks prioritized!"
            } catch {
                aiResponse = "Failed to prioritize tasks."
            }
        }
    }
}

#Preview {
    ContentView()
}
