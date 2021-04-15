//
//  File.swift
//  
//
//  Created by Travis Brigman on 4/15/21.
//

import Fluent
import Vapor

extension Subscription {
    struct UpdateSubscription: Fluent.Migration {
        var name: String { "UpdateSubscription" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("subscriptions")
                .deleteField("ended_on")
                .field("ended_on", .date)
                .update()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("subscriptions").delete()
        }
    }
}
