//
//  File.swift
//  
//
//  Created by Travis Brigman on 3/31/21.
//

import Vapor
import Fluent

final class TagController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tags = routes.grouped("tags")
        
        tags.get(use: retrieveAll)
        tags.get(":tag_id", use: retrieveSingle)
        tags.post(use: create)
        tags.put(":tag_id", use: update)
        tags.delete(":tag_id", use: delete)
    }
    
    
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[Tag]> {
        Tag.query(on: req.db).all()
    }
    
    func retrieveSingle(_ req: Request) throws -> EventLoopFuture<Tag> {
        Tag.find(req.parameters.get("tag_id"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Tag> {
        let tag = try req.content.decode(Tag.self)
        return tag.create(on: req.db).map { tag }
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Tag> {
        let updateData = try req.content.decode(Tag.self)
        return Tag.find(req.parameters.get("tag_id"), on: req.db)
          .unwrap(or: Abort(.notFound)).flatMap { tag in
            tag.label = updateData.label
            return tag.save(on: req.db).map {
              tag
            }
        }
      }
    
    func delete(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Tag.find(req.parameters.get("tag_id"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { tag in
                tag.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

}
