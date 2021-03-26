//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Fluent
import Vapor

extension PostReaction {
    struct Migration: Fluent.Migration {
        var name: String { "CreatePostReaction" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("post_reactions")
                .id()
                .field("rare_user_id", .uuid, .required, .references("rare_users", "id"))
                .field("reaction_id", .uuid, .required, .references("reactions", "id"))
                .field("post_id", .uuid, .required, .references("posts", "id"))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("post_reactions").delete()
        }
    }
}
