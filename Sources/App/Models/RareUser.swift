//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

final class RareUser: Model, Content {
    
    static let schema = "rare_users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "bio")
    var bio: String
    
    @Field(key: "profile_image_url")
    var profileImageUrl: String
    
    @Field(key: "is_staff")
    var isStaff: Bool?
    
    @Field(key: "is_active")
    var isActive: Bool?
    
    
    init() { }
    
    init(id: UUID? = nil,
         username: String,
         passwordHash: String,
         bio: String,
         profileImageUrl: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.bio = bio
        self.profileImageUrl = profileImageUrl
        self.isActive = true
        self.isStaff = false
        
    }
    
    struct Public: Content {
        let username: String
        let id: UUID
        let isActive: Bool?
        let isStaff: Bool?
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
               id: try requireID(),
               isActive: isActive ?? false,
               isStaff: isStaff ?? false
               
        )
    }
}

//Makes sure user field isn't empty, makes sure password is 8 characters or more
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

