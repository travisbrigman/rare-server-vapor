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

extension PostTag {
    
    struct AddOnDeleteFKConstraint: Fluent.Migration {
            var name: String { "UpdatePostTags" }
            
            func prepare(on database: Database) -> EventLoopFuture<Void> {
                let postgresDb = database as! PostgresDatabase
                return postgresDb.sql().raw("""
                    ALTER TABLE post_tags
                    DROP CONSTRAINT post_tags_post_id_fkey,
                    ADD CONSTRAINT post_tags_post_id_fkey
                    FOREIGN KEY (post_id)
                    REFERENCES posts(id)
                    ON DELETE CASCADE;
                    """).run()
            }
        
            
            func revert(on database: Database) -> EventLoopFuture<Void> {
                let postgresDb = database as! PostgresDatabase
                return postgresDb.sql().raw("""
                    ALTER TABLE post_tags
                    DROP CONSTRAINT post_tags_post_id_fkey,
                    ADD CONSTRAINT post_tags_post_id_fkey
                    FOREIGN KEY (post_id)
                    REFERENCES posts(id)
                    ON DELETE CASCADE;
                    """).run()
            }
        }
}
