import SwiftUI

struct GoalSettingView: View {
    @State private var yearlyGoal: String = ""
    @State private var monthlyGoal: String = ""
    @State private var weeklyGoal: String = ""
    @State private var dailyGoal: String = ""
    
    @State private var completedGoals: [CompletedGoal] = []
    
    @State private var newYearlyGoal: String = ""
    @State private var newMonthlyGoal: String = ""
    @State private var newWeeklyGoal: String = ""
    @State private var newDailyGoal: String = ""
    
    // Load goals and completed goals from UserDefaults when the view appears
    private func loadGoals() {
        yearlyGoal = UserDefaults.standard.string(forKey: "yearlyGoal") ?? ""
        monthlyGoal = UserDefaults.standard.string(forKey: "monthlyGoal") ?? ""
        weeklyGoal = UserDefaults.standard.string(forKey: "weeklyGoal") ?? ""
        dailyGoal = UserDefaults.standard.string(forKey: "dailyGoal") ?? ""
        
        if let savedCompletedGoals = UserDefaults.standard.data(forKey: "completedGoals"),
           let decodedGoals = try? JSONDecoder().decode([CompletedGoal].self, from: savedCompletedGoals) {
            completedGoals = decodedGoals
        }
    }
    
    // Save all goals and completed goals to UserDefaults
    private func saveAllGoals() {
        saveGoal(yearlyGoal, forKey: "yearlyGoal")
        saveGoal(monthlyGoal, forKey: "monthlyGoal")
        saveGoal(weeklyGoal, forKey: "weeklyGoal")
        saveGoal(dailyGoal, forKey: "dailyGoal")
        saveCompletedGoals()
    }
    
    // Function to save a goal to UserDefaults
    private func saveGoal(_ goal: String, forKey key: String) {
        UserDefaults.standard.set(goal, forKey: key)
    }
    
    // Save completed goals to UserDefaults
    private func saveCompletedGoals() {
        if let encodedGoals = try? JSONEncoder().encode(completedGoals) {
            UserDefaults.standard.set(encodedGoals, forKey: "completedGoals")
        }
    }
    
    // Function to mark a goal as completed
    private func completeGoal(title: String, type: String) {
        let completedGoal = CompletedGoal(id: UUID(), title: title, type: type)
        completedGoals.append(completedGoal)
        saveCompletedGoals()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // Yearly Goal Section
                    Section(header: Text("Yearly Goal")) {
                        goalRow(
                            goal: $yearlyGoal,
                            newGoal: $newYearlyGoal,
                            goalType: "Yearly",
                            saveKey: "yearlyGoal"
                        )
                    }
                    
                    // Monthly Goal Section
                    Section(header: Text("Monthly Goal")) {
                        goalRow(
                            goal: $monthlyGoal,
                            newGoal: $newMonthlyGoal,
                            goalType: "Monthly",
                            saveKey: "monthlyGoal"
                        )
                    }
                    
                    // Weekly Goal Section
                    Section(header: Text("Weekly Goal")) {
                        goalRow(
                            goal: $weeklyGoal,
                            newGoal: $newWeeklyGoal,
                            goalType: "Weekly",
                            saveKey: "weeklyGoal"
                        )
                    }
                    
                    // Daily Goal Section
                    Section(header: Text("Daily Goal")) {
                        goalRow(
                            goal: $dailyGoal,
                            newGoal: $newDailyGoal,
                            goalType: "Daily",
                            saveKey: "dailyGoal"
                        )
                    }
                }
                
                // Navigation to Completed Goals
                NavigationLink(destination: CompletedGoalsView()) {
                    Text("View Completed Goals")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
            }
            .navigationTitle("Set Goals")
            .onAppear(perform: loadGoals) // Load goals when the view appears
            .onDisappear(perform: saveAllGoals) // Save goals when the view disappears
        }
    }
    
    // Function to generate a row for each goal
    private func goalRow(
        goal: Binding<String>,
        newGoal: Binding<String>,
        goalType: String,
        saveKey: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if goal.wrappedValue.isEmpty {
                // Show TextField and Add Button when no goal is entered
                TextField("Enter your \(goalType.lowercased()) goal", text: newGoal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    goal.wrappedValue = newGoal.wrappedValue
                    saveGoal(goal.wrappedValue, forKey: saveKey)
                    newGoal.wrappedValue = ""
                }) {
                    Text("Add Goal")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                // Display saved goal with a checkmark
                HStack {
                    Text(goal.wrappedValue)
                        .strikethrough(false)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        completeGoal(title: goal.wrappedValue, type: goalType)
                        goal.wrappedValue = ""
                        saveGoal("", forKey: saveKey)
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
            }
        }
    }
}


#Preview {
    GoalSettingView()
}
