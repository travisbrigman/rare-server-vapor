import Fluent
import Vapor

func routes(_ app: Application) throws {

    app.post("users") { req -> EventLoopFuture<RareUser> in
        try RareUser.Create.validate(content: req)
        let create = try req.content.decode(RareUser.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try RareUser(
            username: create.username,
            passwordHash: Bcrypt.hash(create.password),
            bio: create.bio,
            profileImageUrl: create.profileImageUrl
        )
        return user.save(on: req.db)
            .map { user }
    }
    
    let passwordProtected = app.grouped(RareUser.authenticator())
    passwordProtected.post("login") { req -> RareUser in
        try req.auth.require(RareUser.self)
    }

//    try app.register(collection: TodoController())
}
