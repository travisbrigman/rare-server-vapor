//
//  File.swift
//  
//
//  Created by Travis Brigman on 4/13/21.
//

import Foundation
import Vapor
import Fluent

final class SubscriptionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let subscriptions = routes.grouped("subscriptions")
        subscriptions.get(use: retrieveAll)
        
        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.post("subscriptions", use: create)
        
    }
    
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[RareUser]> {
        if let byUser = req.query["author_id"] as UUID? {
            return RareUser.query(on: req.db)
                .filter(\.$id == byUser)
                .all()
        }
        return RareUser.query(on: req.db).all()
    }

    
    func create(_ req: Request) throws -> EventLoopFuture<Subscription> {
        let createSubscription = try req.content.decode(CreateSubscription.self)
        let user = try req.auth.require(RareUser.self)
        
        return RareUser.query(on: req.db)
            .filter(\.$id == createSubscription.author_id)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { author in
                let subscription = Subscription(follower: user.id!, author: author.id!, createdOn: Date(), endedOn: nil)
                
                return subscription.create(on: req.db).map { subscription }
            }
    }
    
    struct CreateSubscription: Content {
        var author_id: UUID
    }
    
}
