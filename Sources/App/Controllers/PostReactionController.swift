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
        let postReactions = routes.grouped(UserToken.authenticator())
        
        postReactions.get("postReactions", use: retrieveAll)
        postReactions.post("postReactions", use: create)
    }
    
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[PostReaction]> {
        PostReaction.query(on: req.db).all()
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<PostReaction> {
        let user = try req.auth.require(RareUser.self)
        let postReaction = try req.content.decode(PostReaction.self)
        
        return postReaction.create(on: req.db).map { postReaction }
    }
    
}
