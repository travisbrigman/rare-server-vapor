//
//  CommentController.swift
//  
//
//  Created by Travis Brigman on 3/26/21.
//

import Foundation
import Vapor
import Fluent

final class CommentController: RouteCollection {
    // This code is unused in the the app
    func boot(routes: RoutesBuilder) throws {
        let categories = routes.grouped("comments")
        categories.get(use: retrieveAll)
        categories.get(":comment_id", use: retrieveSingle)
        categories.post(use: create)
        categories.put(":comment_id", use: update(_:))
        categories.delete(":comment_id", use: delete)
    }
    
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[Comment]> {
        Comment.query(on: req.db).all()
    }
    
    func retrieveSingle(_ req: Request) throws -> EventLoopFuture<Comment> {
        Comment.find(req.parameters.get("comment_id"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Comment> {
        let comment = try req.content.decode(Comment.self)
        return comment.create(on: req.db).map { comment }
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Comment> {
        let updateData = try req.content.decode(CreateComment.self)
        return Comment.find(req.parameters.get("comment_id"), on: req.db)
          .unwrap(or: Abort(.notFound)).flatMap { comment in
            comment.content = updateData.content
            comment.subject = updateData.content
            return comment.save(on: req.db).map {
              comment
            }
        }
      }
    
    func delete(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Comment.find(req.parameters.get("comment_id"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { comment in
                comment.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

    
    struct CreateComment: Content {
        var content: String
        var subject: String
    }
}

