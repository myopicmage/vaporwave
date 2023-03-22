import Fluent
import JWT
import Vapor

extension User {
  struct Create: Content, Validatable {
    var username: String
    var password: String
    var confirmPassword: String

    static func validations(_ validations: inout Validations) {
      validations.add("username", as: String.self, is: !.empty)
      validations.add("password", as: String.self, is: .count(12...))
    }
  }
}

extension User: ModelAuthenticatable, ModelCredentialsAuthenticatable {
  static let usernameKey = \User.$username
  static let passwordHashKey = \User.$password

  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.password)
  }
}

let expirationTime: TimeInterval = 60 * 15

struct UserToken: Content, Authenticatable, JWTPayload {
  var expiration: ExpirationClaim
  var userId: UUID

  init(userId: UUID) {
    self.userId = userId
    self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
  }

  init(user: User) throws {
    self.userId = try user.requireID()
    self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
  }

  func verify(using signer: JWTSigner) throws {
    try self.expiration.verifyNotExpired()
  }
}
