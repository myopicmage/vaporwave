import Vapor

extension Task {
  struct TaskDTO: Content {
    var task: String?
    var due: Date?
    var status: TaskStatus?
    var notes: String?
    var priority: TaskPriority?
    var category: Category?
  }
}
