import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    if app.environment == .production {
        if let databaseURL = Environment.get("DATABASE_URL") {
            try app.databases.use(.postgres(url: databaseURL), as: .psql)
        }
    } else {
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }


    app.migrations.add(CreateCategory())
    app.migrations.add(CreateTodo())

    app.views.use(.leaf)



    // register routes
    try routes(app)
}
