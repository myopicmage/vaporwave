import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        req.logger.debug("Rendering /")
        return try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: TaskController())
}
