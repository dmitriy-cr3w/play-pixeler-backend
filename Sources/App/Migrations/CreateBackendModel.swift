//
//  File.swift
//  
//
//  Created by Dmitriy Holovnia on 04.09.2024.
//

import Fluent

final class CreateBackendModel: AsyncMigration {
    let scheme: String = BackendModel.schema
    typealias keys = BackendModel.FieldKeys
    
    func prepare(on database: Database) async throws {
        try await database.schema(scheme)
            .id()
            .field(keys.title, .string, .required)
            .field(keys.link, .string, .required)
            .field(keys.password, .string, .required)
            .unique(on: keys.link)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(scheme).delete()
    }
}

