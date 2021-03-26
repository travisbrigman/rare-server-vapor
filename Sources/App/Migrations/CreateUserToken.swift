//
//  CreateUserToken.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Foundation
import Fluent

extension UserToken {
    struct Migration: Fluent.Migration {
        var name: String { "CreateUserToken" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user_tokens")
                .id()
                .field("value", .string, .required)
                .field("rare_user_id", .uuid, .required, .references("rare_users", "id"))
                .unique(on: "value")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user_tokens").delete()
        }
    }
}
