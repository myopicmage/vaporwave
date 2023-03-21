import Fluent
import Vapor

struct UserPasswordAuthenticator: AsyncBasicAuthenticator {
  typealias User = App.User

  func authenticate(
    basic: BasicAuthorization,
    for request: Request
  ) async throws {
    if basic.username == "test" && basic.password == "secret" {
      request.auth.login(User())
    }
  }
}

struct UserTokenAuthenticator: AsyncBearerAuthenticator {
  typealias User = App.User

  func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
    if bearer.token == "" {
      request.auth.login(User())
    }
  }
}

struct AuthController: RouteCollection {
  func register(req: Request) async throws -> UserToken {
    try User.Create.validate(content: req)

    let create = try req.content.decode(User.Create.self)

    guard create.password == create.confirmPassword else {
      throw Abort(.badRequest, reason: "passwords did not match")
    }

    let user = try User(
      username: create.username,
      password: Bcrypt.hash(create.password)
    )

    try await user.save(on: req.db)

    return try user.generateToken()
  }

  func boot(routes: RoutesBuilder) throws {
    let authRoutes = routes.grouped("auth")

    authRoutes.post("register", use: register)
  }
}
