//
//  CreateTag.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Fluent
import Vapor

extension Tag {
    struct Migration: Fluent.Migration {
        var name: String { "CreateTag" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("tags")
                .id()
                .field("label", .string, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("tags").delete()
        }
    }
}

