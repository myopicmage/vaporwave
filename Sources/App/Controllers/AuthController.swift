import Fluent
import Vapor

struct ClientTokenResponse: Content {
  var token: String
}

struct AuthController: RouteCollection {
  func register(req: Request) async throws -> ClientTokenResponse {
    try User.Create.validate(content: req)

    let create = try req.content.decode(User.Create.self)

    guard create.password == create.confirmPassword else {
      throw Abort(.badRequest, reason: "passwords did not match")
    }

    let user = try User(
      username: create.username,
      password: Bcrypt.hash(create.password)
    )

    do {
      try await user.save(on: req.db)

      let payload = try UserToken(user: user)

      return ClientTokenResponse(token: try req.jwt.sign(payload))
    } catch let error as DatabaseError where error.isConstraintFailure {
      throw Abort(.badRequest, reason: "Username is taken")
    } catch {
      throw Abort(.badRequest, reason: "Unknown error: \(error)")
    }
  }

  func login(req: Request) async throws -> ClientTokenResponse {
    let user = try req.auth.require(User.self)
    let payload = try UserToken(user: user)

    return ClientTokenResponse(token: try req.jwt.sign(payload))
  }

  func boot(routes: RoutesBuilder) throws {
    let authRoutes = routes.grouped("auth")

    if let allowRegister = Environment.get("ALLOW_REGISTER"), allowRegister == "true" {
      authRoutes
        .grouped(User.credentialsAuthenticator())
        .post("register", use: register)
    }

    authRoutes
      .grouped(User.credentialsAuthenticator())
      .post("login", use: login)
  }
}
