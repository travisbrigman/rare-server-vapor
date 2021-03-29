//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/29/21.
//

import Vapor
import Fluent

extension Reaction {
    struct MigrationSeed: Fluent.Migration {
        var name: String { "CreateReactionSeed" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            let reaction = [
                Reaction(id: UUID(), label: "like", imageUrl: "👍🏼"),
                Reaction(id: UUID(), label: "love", imageUrl: "❤️"),
                Reaction(id: UUID(), label: "curious", imageUrl: "🤔"),
                Reaction(id: UUID(), label: "insightful", imageUrl: "💡"),
                Reaction(id: UUID(), label: "celebrate", imageUrl: "🎉")
            ]
            
            return reaction.create(on: database)
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("reactions").delete()
        }
    }
}

