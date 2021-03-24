//
//  Category.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

final class Category: Model, Content {
    static let schema = "categories"
    
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
