//
//  Comment.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

final class Comment: Model, Content {
    static let schema = "comments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "post_id")
    var post: Post
    
    @Parent(key: "rare_user_id")
    var author: RareUser

    @Field(key: "content")
    var content: String
    
    @Field(key: "subject")
    var subject: String
    
    @Timestamp(key: "created_on", on: .create)
    var createdOn: Date?

    init() { }

    init(id: UUID? = nil, post: Post, author: RareUser, content: String, subject: String) {
        self.id = id
        self.post = post
        self.author = author
        self.content = content
    }
}
