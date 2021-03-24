//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

final class PostReaction: Model, Content {
    static let schema = "post_reactions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "rare_user_id")
    var user: RareUser
    
    @Parent(key: "reaction_id")
    var reaction: Reaction

    @Field(key: "post_id")
    var post: Post

    init() { }

    init(id: UUID? = nil, user: RareUser, reaction: Reaction, post: Post) {
        self.id = id
        self.user = user
        self.reaction = reaction
        self.post = post
    }
}
