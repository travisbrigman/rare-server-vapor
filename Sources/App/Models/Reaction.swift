//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

final class Reaction: Model, Content {
    static let schema = "reactions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "label")
    var label: String
    
    @Field(key: "image_url")
    var imageUrl: String
    

    init() { }

    init(id: UUID? = nil, label: String, imageUrl: String) {
        self.id = id
        self.label = label
        self.imageUrl = imageUrl
    }
}
