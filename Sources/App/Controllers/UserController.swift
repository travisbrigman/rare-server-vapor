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
    }
    
    
    func all(_ req: Request) throws -> EventLoopFuture<[RareUser]> {
        RareUser.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<RareUser> {
        RareUser.find(req.parameters.get("rare_user_id"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func getMyOwnUser(req: Request) throws -> RareUser.Public {
      try req.auth.require(RareUser.self).asPublic()
    }
    
}


extension RareUser {
    struct Create: Content {
        var username: String
        var password: String
        var confirmPassword: String
        var bio: String
        var profileImageUrl: String
    }
    
    func asPublic() throws -> Public {
      Public(username: username,
             id: try requireID())
    }
}

extension RareUser.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension RareUser: ModelAuthenticatable {
    static let usernameKey = \RareUser.$username
    static let passwordHashKey = \RareUser.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension RareUser {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

