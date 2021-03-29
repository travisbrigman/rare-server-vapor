import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    // using a custom error handler
    app.middleware.use(ErrorMiddleware { req, error -> Response in
        // implement custom response...
        .init(status: .internalServerError, version: req.version, headers: .init(), body: .empty)
    })

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
