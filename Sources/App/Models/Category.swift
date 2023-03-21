import Fluent
import Vapor

final class Category: Model, Content {
    static let schema = "categories"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Children(for: \.$category)
    var tasks: [Task]

    init() {}

    init(id: UUID? = nil, name: String) {
      self.id = id
      self.name = name
    }
    
    struct Migration: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema("categories")
                .id()
                .field("name", .string, .required)
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema("categories").delete()
        }
    }
}
