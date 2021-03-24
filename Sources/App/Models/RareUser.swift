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
    var userName: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "bio")
    var bio: String
    
    @Field(key: "profile_image_url")
    var profileImageUrl: String
    

    init() { }

    init(id: UUID? = nil, userName: String, passwordHash: String, bio: String, profileImageUrl: String) {
        self.id = id
        self.userName = userName
        self.passwordHash = passwordHash
        self.bio = bio
        self.profileImageUrl = profileImageUrl
        
    }
}