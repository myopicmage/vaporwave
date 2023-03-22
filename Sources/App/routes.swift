import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        return try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("up") { req -> HTTPStatus in
        .ok
    }

    try app.register(collection: TaskController())
    try app.register(collection: AuthController())
}
