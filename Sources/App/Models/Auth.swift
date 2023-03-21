import Fluent
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

  func generateToken() throws -> UserToken {
    try .init(
      value: [UInt8].random(count: 16).base64,
      userID: self.requireID()
    )
  }
}

extension User: ModelAuthenticatable {
  static let usernameKey = \User.$username
  static let passwordHashKey = \User.$password

  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.password)
  }
}

extension UserToken: ModelTokenAuthenticatable {
  static let valueKey = \UserToken.$value
  static let userKey = \UserToken.$user

  var isValid: Bool {
    true
  }
}

