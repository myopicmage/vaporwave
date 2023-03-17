import Fluent
import Vapor

enum TodoStatus: String, Codable {
    case notStarted, inProgress, finished, delayed
}

enum TodoPriority: String, Codable {
    case low, medium, high, urgent
}

final class Todo: Model, Content {
    static let schema = "todos"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "task")
    var task: String

    @OptionalField(key: "due")
    var due: Date?

    @Enum(key: "status")
    var status: TodoStatus

    @OptionalField(key: "notes")
    var notes: String?

    @Enum(key: "priority")
    var priority: TodoPriority

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @OptionalParent(key: "category_id")
    var category: Category?

    init() { }

    init(
        id: UUID? = nil,
        task: String,
        due: Date? = nil,
        status: TodoStatus = .notStarted,
        notes: String? = nil,
        priority: TodoPriority = .medium
    ) {

        self.id = id
        self.task = task
        self.due = due
        self.status = status
        self.notes = notes
        self.priority = priority
        self.createdAt = nil
        self.updatedAt = nil
    }
}
