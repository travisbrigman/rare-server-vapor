//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/29/21.
//

import Foundation
import Vapor
import Fluent

final class ReactionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let reactions = routes.grouped("reactions")
        
        reactions.get(use: retrieveAll)
        reactions.get(":reaction_id", use: retrieveSingle)
    }
    
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[Reaction]> {
        Reaction.query(on: req.db).all()
    }
    
    func retrieveSingle(_ req: Request) throws -> EventLoopFuture<Reaction> {
        Reaction.find(req.parameters.get("Reaction_id"), on: req.db).unwrap(or: Abort(.notFound))
    }

}
