//
//  UserController.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//
import Fluent
import Vapor

extension RareUser {
    struct Create: Content {
        var userName: String
        var password: String
        var confirmPassword: String
        var bio: String
        var profileImageUrl: String
    }
}

extension RareUser.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("userName", as: String.self, is: !.empty)

        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension RareUser: ModelAuthenticatable {
    static let usernameKey = \RareUser.$userName
    static let passwordHashKey = \RareUser.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

