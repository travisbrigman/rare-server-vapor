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
        //        posts.get(use: retrieveAll)
//        posts.get(":post_id", use: retrieveSingle)
        posts.delete(":post_id", use: delete)
        
        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.post("posts", use: create)
        tokenProtected.put("posts", ":post_id" , use: update)
        tokenProtected.get("posts", use: retrieveAll)
        tokenProtected.get("posts", ":post_id", use: retrieveSingle)
        
    }
    
    
    
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[PostWithCreatedByCurrentUser]> {
        let user = try req.auth.require(RareUser.self)
        
        if let byUser = req.query["user_id"] as UUID? {
            return Post.query(on: req.db)
                .filter(\.$author.$id == byUser)
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
        
        
        return Post.query(on: req.db).with(\.$author).with(\.$category).all().flatMapThrowing { posts in
            
            try posts.map { post in
                
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
    
    func create(_ req: Request) throws -> EventLoopFuture<Post> {
        let data = try req.content.decode(CreatePost.self)
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
    
    func update(_ req: Request) throws -> EventLoopFuture<Post> {
        let updateData = try req.content.decode(CreatePost.self)
        let user = try req.auth.require(RareUser.self)
        return Category.query(on: req.db)
            .filter(\.$id == UUID(updateData.category_id) ?? UUID())
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                let post = Post(authorID: user.id!, categoryID: category.id! , title: updateData.title, publicationDate: Date(), imageUrl: updateData.imageUrl, content: updateData.content, approved: updateData.approved)
                
                return post.save(on: req.db).map { post }
            }
    }
    
    
    func delete(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Post.find(req.parameters.get("post_id"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { post in
                post.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
}


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


