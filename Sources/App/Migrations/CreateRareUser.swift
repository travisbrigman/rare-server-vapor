//
//  CreateUser.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

extension RareUser {
    struct Migration: Fluent.Migration {
        var name: String { "CreateRareUser" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("rare_users")
                .id()
                .field("username", .string, .required)
                .field("password_hash", .string, .required)
                .field("bio", .string)
                .field("profile_image_url", .string)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users").delete()
        }
    }
}
