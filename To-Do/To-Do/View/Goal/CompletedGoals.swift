import SwiftUI

struct CompletedGoalsView: View {
    @State private var completedGoals: [CompletedGoal] = []
    
    // Load completed goals from UserDefaults when the view appears
    private func loadCompletedGoals() {
        if let savedCompletedGoals = UserDefaults.standard.data(forKey: "completedGoals"),
           let decodedGoals = try? JSONDecoder().decode([CompletedGoal].self, from: savedCompletedGoals) {
            completedGoals = decodedGoals
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if completedGoals.isEmpty {
                    Text("No completed goals yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(completedGoals) { goal in
                            HStack {
                                Text("[\(goal.type)] \(goal.title)")
                                    .strikethrough()
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Completed Goals")
            .onAppear {
                loadCompletedGoals() // Load data when the view appears
            }
        }
    }
}

struct CompletedGoal: Identifiable, Codable {
    let id: UUID
    let title: String
    let type: String
}

#Preview {
    CompletedGoalsView()
}
