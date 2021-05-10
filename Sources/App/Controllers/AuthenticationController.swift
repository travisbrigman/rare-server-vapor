//
//  AuthenticationController.swift
//  
//
//  Created by Travis Brigman on 4/1/21.
//

import Foundation
import Vapor
import Fluent

final class AuthenticationController: RouteCollection {
    
    /*
     Most of this was taken directly from the documentation. It barely works but is good enought to get users created and logged in.
     */
    
    func boot(routes: RoutesBuilder) throws {
        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.post("users", use: registerUser)
        tokenProtected.post("users", "login", use: logUserIn)
        tokenProtected.get("me", use: getCurrentUser)
        let passwordProtected = routes.grouped(RareUser.authenticator())
        passwordProtected.post("login", use: logUserIn)
    }
    
    func registerUser(_ req: Request) throws -> EventLoopFuture<UserToken> {
        try RareUser.Create.validate(content: req)
        let create = try req.content.decode(RareUser.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        let user = try RareUser(
                                username: create.username,
                                passwordHash: Bcrypt.hash(create.password),
                                bio: create.bio,
                                profileImageUrl: create.profileImageUrl
                                )
        return user.create(on: req.db).flatMap {
                    do {
                      let token = try user.generateToken()
                      return token.save(on: req.db).map { token }
                    } catch {
                      return req.eventLoop.future(error: error)
                    }
                }
    }
    
    struct userAuth {
        var isValid: Bool
        var token: UserToken
    }

    func logUserIn(_ req: Request) throws -> EventLoopFuture<UserToken> {
        let user = try req.auth.require(RareUser.self)
        let token = try user.generateToken()
        return token.save(on: req.db)
            .map { token }
    }
    
    func getCurrentUser(_ req: Request) throws -> RareUser {
        try req.auth.require(RareUser.self)
    }
    
    
}
