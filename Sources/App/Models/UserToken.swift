import Fluent
import Vapor

final class UserToken: Model, Content {
  static let schema = "user_tokens"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "value")
  var value: String

  @Parent(key: "user_id")
  var user: User

  init() { }

  init(id: UUID? = nil, value: String, userID: User.IDValue) {
    self.id = id
    self.value = value
    self.$user.id = userID
  }

  struct Migration: AsyncMigration {
    func prepare(on database: Database) async throws {
      try await database.schema("user_tokens")
        .id()
        .field("value", .string, .required)
        .field("user_id", .uuid, .required, .references("users", "id"))
        .unique(on: "value")
        .create()
    }

    func revert(on database: Database) async throws {
      try await database.schema("user_tokens").delete()
    }
  }
}
