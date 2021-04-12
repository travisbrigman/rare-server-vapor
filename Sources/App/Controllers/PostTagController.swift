//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/31/21.
//

import Foundation
import Vapor
import Fluent

final class PostTagController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let postReactions = routes.grouped("postTags")
        
        postReactions.get(use: retrieveAll)
        postReactions.post(use: create)
        postReactions.delete(":post_tag_id", use: delete)
    }
    
    struct CreatePostTag: Content {
        let tag: UUID
        let post: UUID
    }
    
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[PostTag]> {
        if let byTagId = req.query["tag_id"] as UUID? {
            return PostTag.query(on: req.db)
                .filter(\.$tag.$id == byTagId)
                .with(\.$post)
                .with(\.$tag)
                .all()
        }
        
        if let byPostId = req.query["post_id"] as UUID? {
            return PostTag.query(on: req.db)
                .filter(\.$post.$id == byPostId)
                .with(\.$post)
                .with(\.$tag)
                .all()
        }
        
        return PostTag.query(on: req.db).with(\.$post).with(\.$tag).all()
    }

    
    func create(_ req: Request) throws -> EventLoopFuture<PostTag> {
        let data = try req.content.decode(CreatePostTag.self)
        let postTag = PostTag(tag: data.tag, post: data.post)
        return postTag.create(on: req.db).map { postTag }
    }
    
    func delete(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        PostTag.find(req.parameters.get("post_tag_id"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { postTag in
                postTag.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
}
