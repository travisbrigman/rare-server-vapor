import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let userController = RareUserController()
    let categoryController = CategoryController()
    let commentController = CommentController()
    let postController = PostController()
    let postReactionsController = PostReactionController()
    let postTagController = PostTagController()
    let tagController = TagController()
    let authenticationController = AuthenticationController()
    let subscriptionController = SubscriptionController()

    try app.register(collection: userController)
    try app.register(collection: categoryController)
    try app.register(collection: commentController)
    try app.register(collection: postController)
    try app.register(collection: postReactionsController)
    try app.register(collection: postTagController)
    try app.register(collection: tagController)
    try app.register(collection: authenticationController)
    try app.register(collection: subscriptionController)
}
