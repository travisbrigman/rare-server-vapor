//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

final class PostTag: Model, Content {
    static let schema = "post_tags"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "tag_id")
    var tag: Tag
    
    @Parent(key: "post_id")
    var post: Post

    init() { }

    init(id: UUID? = nil, tag: Tag, post: Post) {
        self.id = id
        self.tag = tag
        self.post = post
    }
}
