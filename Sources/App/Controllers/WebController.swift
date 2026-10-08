//
//  File.swift
//  
//
//  Created by Dmitriy Holovnia on 14.01.2024.
//

import Foundation
import Fluent
import Vapor

final class WebModel: Model, Content, @unchecked Sendable {
    static let schema = Schema.webs.rawValue
    
    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.link) var link: String
    
    init() {}
    
    init(id: UUID? = nil, link: String) {
        self.id = id
        self.link = link
    }
    
    enum FieldKeys {
        static var link: FieldKey { "link" }
    }
}

struct WebModelDTO: Codable {
    let link: String
}

final class CreateLinkModel: AsyncMigration {
    let scheme: String = WebModel.schema
    typealias keys = WebModel.FieldKeys
    
    func prepare(on database: Database) async throws {
        try await database.schema(scheme)
            .id()
            .field(keys.link, .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(scheme).delete()
    }
}

struct WebModelController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let group = routes.grouped("api", "web")
        group.get(use: handleGet)
        group.post(use: handleCreate)
        group.delete(use: handleDelete)
    }
    
    func handleGet(_ req: Request) async throws -> String {
        let model = try await WebModel.query(on: req.db).first()
        return model?.link ?? "No link"
    }
    
    func handleCreate(_ req: Request) async throws -> String {
        let content = try req.content.decode(WebModelDTO.self)
        let model = WebModel(link: content.link)
        try await WebModel.query(on: req.db).delete()
        try await model.create(on: req.db)
        return model.link
    }
    
    func handleDelete(_ req: Request) async throws -> String {
        let model = try await WebModel.query(on: req.db).first()
        try await WebModel.query(on: req.db).delete()
        if let link = model?.link {
            return "Link was deleted: \(link)"
        } else {
            return "There was no link."
        }
    }
    
}
