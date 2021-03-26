//
//  CreateCategory.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Fluent
import Vapor

extension Category {
    struct Migration: Fluent.Migration {
        var name: String { "CreateCategory" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("categories")
                .id()
                .field("label", .string, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("categories").delete()
        }
    }
}
