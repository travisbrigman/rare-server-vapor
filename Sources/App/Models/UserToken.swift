//
//  UserToken.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Foundation
import Fluent
import Vapor

final class UserToken: Model, Content {
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "rare_user_id")
    var user: RareUser

    init() { }

    init(id: UUID? = nil, value: String, userID: RareUser.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}
