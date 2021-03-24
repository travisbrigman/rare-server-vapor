//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

final class Tag: Model, Content {
    static let schema = "tags"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "label")
    var label: String

    init() { }

    init(id: UUID? = nil, label: String) {
        self.id = id
        self.label = label
    }
}
