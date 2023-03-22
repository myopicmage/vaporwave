import Fluent
import Vapor

final class User: Model, Content {
  static let schema = "users"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "username")
  var username: String

  @Field(key: "password")
  var password: String

  @OptionalField(key: "first_name")
  var firstName: String?

  @OptionalField(key: "last_name")
  var lastName: String?

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  init() {}

  init(
    id: UUID? = nil,
    username: String,
    password: String,
    firstName: String? = nil,
    lastName: String? = nil
  ) {
    self.id = id
    self.username = username
    self.password = password
    self.firstName = firstName
    self.lastName = lastName
  }
}

extension User {
  struct Migration: AsyncMigration {
    func prepare(on database: Database) async throws {
      try await database.schema(User.schema)
        .id()
        .field("username", .string, .required)
        .field("password", .string, .required)
        .field("first_name", .string)
        .field("last_name", .string)
        .field("created_at", .datetime)
        .field("updated_at", .datetime)
        .unique(on: "username")
        .create()
    }

    func revert(on database: Database) async throws {
      try await database.schema(User.schema).delete()
    }
  }
}
