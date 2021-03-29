import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let userController = RareUserController()
    let categoryController = CategoryController()
    let commentController = CommentController()
    let postController = PostController()
    let postReactionsController = PostReactionController()

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
    passwordProtected.post("login") { req -> EventLoopFuture<UserToken> in
        let user = try req.auth.require(RareUser.self)
        let token = try user.generateToken()
        return token.save(on: req.db)
            .map { token }
    }
    
    let tokenProtected = app.grouped(UserToken.authenticator())
    tokenProtected.get("me") { req -> RareUser in
        try req.auth.require(RareUser.self)
    }
    

    try app.register(collection: userController)
    try app.register(collection: categoryController)
    try app.register(collection: commentController)
    try app.register(collection: postController)
    try app.register(collection: postReactionsController)
}
