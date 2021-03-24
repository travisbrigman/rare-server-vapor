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
    
    @Parent(key: "rare_user")
    var follower: RareUser
    
    @Parent(key: "rare_user")
    var author: RareUser
    
    @Timestamp(key: "created_on", on: .create)
    var createdOn: Date?
    
    @Timestamp(key: "ended_on", on: .delete)
    var endedOn: Date?

    init() { }

    init(id: UUID? = nil, follower: RareUser, author: RareUser, createdOn: Date, endedOn: Date) {
        self.id = id
        self.follower = follower
        self.author = author
        self.createdOn = createdOn
        self.endedOn = endedOn
    }
}
