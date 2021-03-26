//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Fluent
import Vapor

extension Reaction {
    struct Migration: Fluent.Migration {
        var name: String { "CreateReaction" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("reactions")
                .id()
                .field("label", .string, .required)
                .field("image_url", .string, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("reactions").delete()
        }
    }
}
