import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)

    // Only add this if you want to enable the default per-route logging
    let routeLogging = RouteLoggingMiddleware(logLevel: .info)

    // Add the default error middleware
    let error = ErrorMiddleware.default(environment: app.environment)
    // Clear any existing middleware.
    app.middleware = .init()
    app.middleware.use(cors)
    app.middleware.use(routeLogging)
    app.middleware.use(error)
    
//    app.databases.use(.postgres(hostname: "localhost", username: "postgres", password: "", database: "raredb"), as: .psql)
    
    let databaseName: String
    let databasePort: Int
    if (app.environment == .testing) {
      databaseName = "raredb"
      if let testPort = Environment.get("DATABASE_PORT") {
        databasePort = Int(testPort) ?? 5432
      } else {
        databasePort = 5432
      }
    } else {
      databaseName = "raredb"
      databasePort = 5432
    }
    
    if var config = Environment.get("DATABASE_URL")
        .flatMap(URL.init)
        .flatMap(PostgresConfiguration.init) {
      config.tlsConfiguration = .forClient(
        certificateVerification: .none)
      app.databases.use(.postgres(
        configuration: config
      ), as: .psql)
    } else {
      app.databases.use(
        .postgres(
          hostname: Environment.get("DATABASE_HOST") ??
            "localhost",
          port: databasePort,
          username: Environment.get("DATABASE_USERNAME") ??
            "postgres",
          password: Environment.get("DATABASE_PASSWORD") ??
            "",
          database: Environment.get("DATABASE_NAME") ??
            databaseName),
        as: .psql)
    }
//first migrations to create database
    app.migrations.add(RareUser.Migration())
    app.migrations.add(UserToken.Migration())
    app.migrations.add(Category.Migration())
    app.migrations.add(Post.Migration())
    app.migrations.add(Reaction.Migration())
    app.migrations.add(PostReaction.Migration())
    app.migrations.add(Tag.Migration())
    app.migrations.add(PostTag.Migration())
    app.migrations.add(Comment.Migration())
    app.migrations.add(Subscription.Migration())
//additional migrations to add/fix stuff
    app.migrations.add(Reaction.MigrationSeed())
    app.migrations.add(PostReaction.AddOnDeleteFKConstraint())
    app.migrations.add(PostTag.AddOnDeleteFKConstraint())
    app.migrations.add(Subscription.UpdateSubscription())
    app.migrations.add(RareUser.UpdateRareUser())
    
    app.logger.logLevel = .trace

    // register routes
    try routes(app)
}
