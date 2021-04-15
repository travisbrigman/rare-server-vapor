//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

final class Subscription: Model, Content {
    static let schema = "subscriptions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "follower")
    var follower: RareUser
    
    @Parent(key: "author")
    var author: RareUser
    
    @Timestamp(key: "created_on", on: .create)
    var createdOn: Date?
    
    @Timestamp(key: "ended_on", on: .delete)
    var endedOn: Date?

    init() { }

    init(id: UUID? = nil, follower: UUID, author: UUID, createdOn: Date?, endedOn: Date?) {
        self.id = id
        $follower.id = follower
        $author.id = author
        self.createdOn = createdOn
        self.endedOn = endedOn
    }
}
