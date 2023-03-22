import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import JWT
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  app.logger.info("Environment detected: \(app.environment.name)")

  app.logger.info("Setting up JWT")

  guard let secretKey = Environment.get("JWT_SECRET") else {
    app.logger.error("Unable to load JWT key")

    return app.shutdown()
  }

  app.jwt.signers.use(.hs256(key: secretKey))

  // cors cors cors cors
  let corsConfig = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
    allowedHeaders: [
      .accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent,
      .accessControlAllowOrigin,
    ]
  )
  app.middleware.use(CORSMiddleware(configuration: corsConfig), at: .beginning)

  app.logger.info("Setting up database")

  switch app.environment {
  case .production:
    app.logger.info("Setting up postgres")

    app.logger.debug("Looking for database url")

    guard let databaseURL = Environment.get("DATABASE_URL") else {
      app.logger.error("Unable to find database url!")
      return app.shutdown()
    }

    app.logger.debug("Found database url. Setting up postgres")

    try app.databases.use(.postgres(url: databaseURL), as: .psql)
  default:
    app.logger.info("Setting up sqlite")
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
  }

  app.logger.info("Adding migrations")

  app.migrations.add(Category.Migration())
  app.migrations.add(Task.Migration())
  app.migrations.add(User.Migration())

  app.logger.info("Attempting to run migrations")
  try await app.autoMigrate()

  app.logger.info("Migrations run. Adding leaf.")

  app.views.use(.leaf)

  app.logger.info("Registering routes.")
  try routes(app)
}
