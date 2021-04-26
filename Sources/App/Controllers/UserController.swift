//
//  UserController.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//
import Fluent
import Vapor

final class RareUserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: all)
        users.get(":rare_user_id", use: getHandler)
        
        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.get("currentuser", use: getMyOwnUser)
    }
    
    
    func all(_ req: Request) throws -> EventLoopFuture<[RareUser]> {
        RareUser.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<RareUser> {
        RareUser.find(req.parameters.get("rare_user_id"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func getMyOwnUser(req: Request) throws -> RareUser.Public {
      try req.auth.require(RareUser.self).asPublic() // this returns an object that only has "public" info like name, email, etc. It doesn't send back any password hash or token stuff - this was taken from either the docs or an article somewhere.
    }
    
}


