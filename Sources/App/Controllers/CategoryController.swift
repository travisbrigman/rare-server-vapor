//
//  CategoryController.swift
//  
//
//  Created by Travis Brigman on 3/26/21.
//

import Foundation
import Vapor
import Fluent

final class CategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categories = routes.grouped("categories")
        categories.get(use: retrieveAll)
        categories.get(":category_id", use: retrieveSingle)
        categories.post(use: create)
        categories.put(":category_id", use: update(_:))
        categories.delete(":category_id", use: delete)
    }
    
    func retrieveAll(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Category.query(on: req.db).all()
    }
    
    func retrieveSingle(_ req: Request) throws -> EventLoopFuture<Category> {
        Category.find(req.parameters.get("category_id"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        return category.create(on: req.db).map { category }
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Category> {
        let updateData = try req.content.decode(CreateCategory.self)
        return Category.find(req.parameters.get("category_id"), on: req.db)
          .unwrap(or: Abort(.notFound)).flatMap { category in
            category.label = updateData.label
            return category.save(on: req.db).map {
              category
            }
        }
      }
    
    func delete(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Category.find(req.parameters.get("category_id"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { category in
                category.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

    
    struct CreateCategory: Content {
        var label: String
    }
}
