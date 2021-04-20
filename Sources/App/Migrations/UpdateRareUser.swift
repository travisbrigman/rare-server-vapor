//
//  File.swift
//  
//
//  Created by Travis Brigman on 4/15/21.
//

import Fluent
import Vapor

extension RareUser {
    struct UpdateRareUser: Fluent.Migration {
        var name: String { "UpdateRareUser" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("rare_users")
                .field("is_staff", .bool)
                .field("is_active", .bool)
                .update()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("rare_users").delete()
        }
    }
}
