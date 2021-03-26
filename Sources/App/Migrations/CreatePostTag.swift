//
//  CreatePostTag.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Fluent
import Vapor

extension PostTag {
    struct Migration: Fluent.Migration {
        var name: String { "CreatPostTag" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("post_tags")
                .id()
                .field("tag_id", .uuid, .required, .references("tags", "id"))
                .field("post_id", .uuid, .required, .references("posts", "id"))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("post_tags").delete()
        }
    }
}
