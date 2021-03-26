//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Fluent
import Vapor

extension Comment {
    struct Migration: Fluent.Migration {
        var name: String { "CreateComment" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("comments")
                .id()
                .field("rare_user_id", .uuid, .required, .references("rare_users", "id"))
                .field("post_id", .uuid, .references("posts", "id"))
                .field("content", .string, .required)
                .field("subject", .string, .required)
                .field("created_on", .date, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("comments").delete()
        }
    }
}

