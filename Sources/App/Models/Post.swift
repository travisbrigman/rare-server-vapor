//
//  Post.swift
//  
//
//  Created by Travis Brigman on 3/24/21.
//

import Fluent
import Vapor

final class Post: Model, Content {
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "rare_user_id")
    var author: RareUser
    
    @Parent(key: "category_id")
    var category: Category

    @Field(key: "title")
    var title: String
    
    @Timestamp(key: "publication_date", on: .create)
    var publicationDate: Date?
    
    @Field(key: "image_url")
    var imageUrl: String
    
    @Field(key: "content")
    var content: String
    
    @Field(key: "approved")
    var approved: Bool

    init() { }

    init(id: UUID? = nil, authorID: UUID, categoryID: UUID, title: String, publicationDate: Date, imageUrl: String, content: String, approved: Bool) {
        self.id = id
        $author.id = authorID
        $category.id = categoryID
        self.title = title
        self.publicationDate = publicationDate
        self.imageUrl = imageUrl
        self.content = content
        self.approved = approved
    }
}
