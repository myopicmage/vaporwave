import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.logger.info("Environment detected: \(app.environment.name)")
    app.logger.info("Setting up database")

    switch app.environment {
        case .production:
            app.logger.info("Setting up postgres")

            app.logger.debug("Looking for database url")

            if let databaseURL = Environment.get("DATABASE_URL") {
                app.logger.debug("Found database url. Setting up postgres")
                try app.databases.use(.postgres(url: databaseURL), as: .psql)
            } else {
                app.logger.debug("Unable to find database url!")
                app.shutdown()
            }
        default:
            app.logger.info("Setting up sqlite")
            app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }

    app.logger.info("Adding migrations")

    app.migrations.add(Category.Migration())
    app.migrations.add(Task.Migration())

    app.logger.info("Attempting to run migrations")
    try await app.autoMigrate()

    app.logger.info("Migrations run. Adding lead.")

    app.views.use(.leaf)

    app.logger.info("Registering routes.")
    try routes(app)
}
