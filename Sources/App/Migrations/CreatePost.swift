//
//  CreatePost.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Fluent
import Vapor

extension Post {
    struct Migration: Fluent.Migration {
        var name: String { "CreatePost" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("posts")
                .id()
                .field("rare_user_id", .uuid, .required, .references("rare_users", "id"))
                .field("category_id", .uuid, .references("categories", "id"))
                .field("title", .string, .required)
                .field("publication_date", .date, .required)
                .field("image_url", .string)
                .field("content", .string, .required)
                .field("approved", .bool)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("posts").delete()
        }
    }
}
