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

//‼️THIS WAS BOILERPLATE CODE THAT DIDN'T WORK
//    app.databases.use(.postgres(
//        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
//        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
//        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
//        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
//        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
//    ), as: .psql)
    
    app.databases.use(.postgres(hostname: "localhost", username: "postgres", password: "", database: "raredb"), as: .psql)

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
    
    app.migrations.add(Reaction.MigrationSeed())
    
    app.logger.logLevel = .trace

    // register routes
    try routes(app)
}
