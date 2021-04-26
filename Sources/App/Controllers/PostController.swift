//
//  PostController.swift
//  
//
//  Created by Travis Brigman on 3/26/21.
//

import Foundation
import Vapor
import Fluent

final class PostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        posts.delete(":post_id", use: delete)
        
        //these use the authenticator to retrieve the user object from db by using the bearer token
        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.post("posts", use: create)
        tokenProtected.put("posts", ":post_id" , use: update)
        tokenProtected.get("posts", use: retrieveAll)
        tokenProtected.get("posts", ":post_id", use: retrieveSingle)
        
    }
    
    
    //http://127.0.0.1:8080/posts
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[PostWithCreatedByCurrentUser]> {
        let user = try req.auth.require(RareUser.self)
        
        //filters using query string parameter
        //GET http://127.0.0.1:8080/posts?category_id=FD33AC6C-3F70-4B4E-959C-A105633AC07F
        if let byUser = req.query["user_id"] as UUID? {
            return Post.query(on: req.db)
                .filter(\.$author.$id == byUser)
                .with(\.$author) //eager loading
                .with(\.$category) // more eager loading
                .all()
                .flatMapThrowing { posts in  //this is needed to add the createdByCurrentUser property
                    posts.map { post in
                        
                        if  post.author.id == user.id {
                            post.createdByCurrentUser = true
                        } else {
                            post.createdByCurrentUser = false
                        }
                        return PostWithCreatedByCurrentUser(
                            id: post.id!, // probably bad form to force unwrap this
                            author: post.author,
                            category: post.category,
                            title: post.title,
                            publicationDate: post.publicationDate!,
                            imageUrl: post.imageUrl,
                            content: post.content,
                            approved: post.approved,
                            createdByCurrentUser: post.createdByCurrentUser
                        )
                    }
                }
        }
        
        //filters using query string parameter
        //GET http://127.0.0.1:8080/posts?category_id=FD33AC6C-3F70-4B4E-959C-A105633AC07F
        if let byCategory = req.query["category_id"] as UUID? {
            return Post.query(on: req.db)
                .filter(\.$category.$id == byCategory)
                .with(\.$author)
                .with(\.$category)
                .all()
                .flatMapThrowing { posts in
                    posts.map { post in
                        
                        if  post.author.id == user.id {
                            post.createdByCurrentUser = true
                        } else {
                            post.createdByCurrentUser = false
                        }
                        return PostWithCreatedByCurrentUser(
                            id: post.id!,
                            author: post.author,
                            category: post.category,
                            title: post.title,
                            publicationDate: post.publicationDate!,
                            imageUrl: post.imageUrl,
                            content: post.content,
                            approved: post.approved,
                            createdByCurrentUser: post.createdByCurrentUser
                        )
                    }
                }
        }
        
        //if neither of the query strings are present, we just return all the posts unfiltered
        return Post.query(on: req.db)
            .with(\.$author)
            .with(\.$category)
            .all()
            .flatMapThrowing { posts in
            
            posts.map { post in
                
                if  post.author.id == user.id {
                    post.createdByCurrentUser = true
                } else {
                    post.createdByCurrentUser = false
                }
                return PostWithCreatedByCurrentUser(
                    id: post.id!,
                    author: post.author,
                    category: post.category,
                    title: post.title,
                    publicationDate: post.publicationDate!,
                    imageUrl: post.imageUrl,
                    content: post.content,
                    approved: post.approved,
                    createdByCurrentUser: post.createdByCurrentUser
                )
            }
        }
    }
    
    //GET http://127.0.0.1:8080/posts/69B290F7-872E-48CE-B465-2400FAB86DF5
    func retrieveSingle(_ req: Request) throws -> EventLoopFuture<PostWithCreatedByCurrentUser> {
        let user = try req.auth.require(RareUser.self)
        let postID = try req.parameters.require("post_id", as: UUID.self)
        
        return Post.query(on: req.db).filter(\.$id == postID)
            .with(\.$author)
            .with(\.$category)
            .first()
            .flatMapThrowing { posts in
                posts.map { post in
                    
                    if  post.author.id == user.id {
                        post.createdByCurrentUser = true
                    } else {
                        post.createdByCurrentUser = false
                    }
                    return PostWithCreatedByCurrentUser(
                        id: post.id!,
                        author: post.author,
                        category: post.category,
                        title: post.title,
                        publicationDate: post.publicationDate!,
                        imageUrl: post.imageUrl,
                        content: post.content,
                        approved: post.approved,
                        createdByCurrentUser: post.createdByCurrentUser
                    )
                }
            }
            .unwrap(or: Abort(.notFound))
    }
    
    //POST http://127.0.0.1:8080/posts
    func create(_ req: Request) throws -> EventLoopFuture<Post> {
        let data = try req.content.decode(CreatePost.self) //notice use of DTO (see below)
        let user = try req.auth.require(RareUser.self)
        return Category.query(on: req.db)
            .filter(\.$id == UUID(data.category_id) ?? UUID())
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                let post = Post(authorID: user.id!,
                                categoryID: category.id!,
                                title: data.title,
                                publicationDate: Date(),
                                imageUrl: data.imageUrl,
                                content: data.content,
                                approved: data.approved)
                return post.create(on: req.db).map { post }
            }
    }
    
    //PUT http://127.0.0.1:8080/posts/77CA60D4-1893-42FA-9692-22CD0FE04773
    func update(_ req: Request) throws -> EventLoopFuture<Post> {
        let updateData = try req.content.decode(CreatePost.self)
        let user = try req.auth.require(RareUser.self)
        return Post.find(req.parameters.get("post_id"), on: req.db) //finds the first post matching the id
            .unwrap(or: Abort(.notFound)) // or sends back a not found
            .flatMap { post in
                post.$author.id = user.id!
                post.$category.id = UUID(updateData.category_id)!
                post.imageUrl = updateData.imageUrl
                post.title = updateData.title
                post.content = updateData.content
                post.publicationDate = Date()
                post.approved = updateData.approved
                
                return post.save(on: req.db).map { post }
            }
    }
    
    //DELETE http://127.0.0.1:8080/posts/071C98BB-195E-4DDF-B500-01EC32515CAF
    func delete(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Post.find(req.parameters.get("post_id"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { post in
                post.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
}

/*
 From the Ray Wanderlich Vapor Book:
    A DTO is a type that represents what a client should send or receive. Your route handler then accepts a DTO and converts it into something your code can use.
 */
struct CreatePost: Content {
    var category_id: String
    var title: String
    var imageUrl: String
    var content: String
    var approved: Bool
}

struct PostWithCreatedByCurrentUser: Content {
    var id: UUID
    var author: RareUser
    var category: Category
    var title: String
    var publicationDate: Date
    var imageUrl: String
    var content: String
    var approved: Bool
    var createdByCurrentUser: Bool
}


