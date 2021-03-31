//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/29/21.
//

import Foundation
import Vapor
import Fluent

final class PostReactionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let postReactions = routes.grouped("postReactions")
        
        postReactions.get(use: retrieveAll)
        postReactions.post(use: create)
        postReactions.delete(":post_reaction_id", use: delete)
    }
    
    struct CreatePostReaction: Content {
        let post: UUID
        let user: UUID
        let reaction: UUID
    }
    
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[PostReaction]> {
        PostReaction.query(on: req.db).all()
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<PostReaction> {
        let data = try req.content.decode(CreatePostReaction.self)
        let postReaction = PostReaction(user: data.user, reaction: data.reaction, post: data.post)
        return postReaction.create(on: req.db).map { postReaction }
    }
    
    func delete(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        PostReaction.find(req.parameters.get("post_reaction_id"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { postReaction in
                postReaction.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
}
