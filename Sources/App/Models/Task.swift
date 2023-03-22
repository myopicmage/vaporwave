import Fluent
import Vapor

final class Task: Model, Content {
  static let schema = "tasks"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "task")
  var task: String

  @OptionalField(key: "due")
  var due: Date?

  @Enum(key: "status")
  var status: TaskStatus

  @OptionalField(key: "notes")
  var notes: String?

  @Enum(key: "priority")
  var priority: TaskPriority

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  @OptionalParent(key: "category_id")
  var category: Category?

  init() {}

  init(
    id: UUID? = nil,
    task: String,
    due: Date? = nil,
    status: TaskStatus = .notStarted,
    notes: String? = nil,
    priority: TaskPriority = .medium
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

  enum TaskStatus: String, Codable {
    case notStarted, inProgress, finished, delayed
  }

  enum TaskPriority: String, Codable {
    case low, medium, high, urgent
  }
}

extension Task {

  struct Migration: AsyncMigration {
    func prepare(on database: Database) async throws {
      let todoStatus = try await database.enum("todoStatus")
        .case("notStarted")
        .case("inProgress")
        .case("finished")
        .case("delayed")
        .create()

      let todoPriority = try await database.enum("todoPriority")
        .case("low")
        .case("medium")
        .case("high")
        .case("urgent")
        .create()

      try await database.schema(Task.schema)
        .id()
        .field("task", .string, .required)
        .field("due", .datetime)
        .field("status", todoStatus, .required)
        .field("notes", .string)
        .field("priority", todoPriority, .required)
        .field("created_at", .datetime)
        .field("updated_at", .datetime)
        .field("category_id", .uuid, .references("categories", "id"))
        .create()
    }

    func revert(on database: Database) async throws {
      try await database.schema(Task.schema).delete()
      try await database.enum("todoStatus").delete()
      try await database.enum("todoPriority").delete()
    }
  }
}
