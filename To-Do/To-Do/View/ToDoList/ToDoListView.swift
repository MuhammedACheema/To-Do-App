import SwiftUI

struct TodoListView: View {
    @State private var todoItems: [TodoItem] = [] {
        didSet {
            saveTasks()
        }
    }
    @State private var newTaskTitle: String = ""
    @State private var selectedCategory: String = "Personal" // Default category
    @State private var showCompletedTasks = false
    
    let categories = ["All", "Personal", "Work", "Others"]
    
    var body: some View {
        VStack {
            Text("To-Do List")
                .font(.largeTitle)
                .padding(.top)
            
            // Input Section
            VStack(alignment: .leading) {
                TextField("New Task", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical)
                    .disabled(selectedCategory == "All") // Disable input when "All" is selected
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button(action: addTask) {
                    Text("Add Task")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedCategory == "All" ? Color.gray : Color.blue) // Gray out when disabled
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(selectedCategory == "All") // Disable button when "All" is selected
                
                if selectedCategory == "All" {
                    Text("Please select a specific category to add a new task.")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
            }
            .padding()
            
            // Show Completed Tasks Toggle
            Toggle(isOn: $showCompletedTasks) {
                Text("Show Completed Tasks")
            }
            .padding(.horizontal)
            
            // List of Tasks
            List {
                ForEach(filteredTasks) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            
                            if let note = item.note {
                                Text(note)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            if let deadline = item.deadline {
                                Text("Due: \(deadline, style: .date)")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            
                            Text("Category: \(item.category)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Mark as Complete / Incomplete Button
                        Button(action: {
                            toggleTaskCompletion(for: item)
                        }) {
                            Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isComplete ? .green : .gray)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: deleteTask)
            }
        }
        .navigationTitle("To-Do List")
        .onAppear(perform: loadTasks)
    }
    
    // Computed property to filter tasks based on selected category and completion status
    private var filteredTasks: [TodoItem] {
        todoItems.filter { item in
            (selectedCategory == "All" || item.category == selectedCategory) &&
            item.isComplete == showCompletedTasks
        }
    }
    
    // Function to Add Task
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        let newTask = TodoItem(id: UUID(), title: newTaskTitle, category: selectedCategory == "All" ? "Personal" : selectedCategory)
        todoItems.append(newTask)
        newTaskTitle = ""
    }
    
    // Function to Delete Task
    private func deleteTask(at offsets: IndexSet) {
        todoItems.remove(atOffsets: offsets)
    }
    
    // Function to Toggle Task Completion
    private func toggleTaskCompletion(for item: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[index].isComplete.toggle()
        }
    }
    
    // Save tasks to UserDefaults
    private func saveTasks() {
        if let data = try? JSONEncoder().encode(todoItems) {
            UserDefaults.standard.set(data, forKey: "todoItems")
        }
    }
    
    // Load tasks from UserDefaults
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "todoItems"),
           let savedTasks = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todoItems = savedTasks
        }
    }
}

struct TodoItem: Identifiable, Codable {
    let id: UUID
    let title: String
    var isComplete: Bool = false
    var note: String? = nil
    var deadline: Date? = nil
    var category: String
}

#Preview {
    TodoListView()
}
