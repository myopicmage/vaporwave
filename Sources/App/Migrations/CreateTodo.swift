import Fluent

struct CreateTodo: AsyncMigration {
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

        try await database.schema("todos")
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
        try await database.schema("todos").delete()
        try await database.enum("todoStatus").delete()
        try await database.enum("todoPriority").delete()
    }
}
