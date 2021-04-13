//
//  File.swift
//  
//
//  Created by Travis Brigman on 4/12/21.
//

import Fluent
import Vapor
import FluentSQL
import FluentPostgresDriver

extension PostReaction {
    
    struct AddOnDeleteFKConstraint: Fluent.Migration {
            var name: String { "UpdatePostReaction" }
            
            func prepare(on database: Database) -> EventLoopFuture<Void> {
                let postgresDb = database as! PostgresDatabase
                return postgresDb.sql().raw("""
                    ALTER TABLE post_reactions
                    DROP CONSTRAINT post_reactions_post_id_fkey,
                    ADD CONSTRAINT post_reactions_post_id_fkey
                    FOREIGN KEY (post_id)
                    REFERENCES posts(id)
                    ON DELETE CASCADE;
                    """).run()
            }
        
            
            func revert(on database: Database) -> EventLoopFuture<Void> {
                let postgresDb = database as! PostgresDatabase
                return postgresDb.sql().raw("""
                    ALTER TABLE post_reactions
                    UPDATE FOREIGN KEY(post_reactions_post_id_fkey)
                    REFERENCES post(post_id)
                    ON DELETE CASCADE;
                    """).run()
            }
        }
}
