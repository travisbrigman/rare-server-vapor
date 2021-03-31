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
        PostTag.query(on: req.db).all()
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
