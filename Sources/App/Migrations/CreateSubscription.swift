//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Fluent
import Vapor

extension Subscription {
    struct Migration: Fluent.Migration {
        var name: String { "CreateSubscription" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("subscriptions")
                .id()
                .field("author", .uuid, .required, .references("rare_users", "id"))
                .field("follower", .uuid, .references("rare_users", "id"))

                .field("created_on", .date, .required)
                .field("ended_on", .date, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("subscriptions").delete()
        }
    }
}

