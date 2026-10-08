//
//  File.swift
//
//
//  Created by Dmitriy Holovnia on 21.12.2023.
//

import Foundation
import Fluent

final class CreateUserModel: AsyncMigration {
    let scheme: String = UserModel.schema
    typealias keys = UserModel.FieldKeys
    
    func prepare(on database: Database) async throws {
        try await database.schema(scheme)
            .id()
            .field(keys.username, .string, .required)
            .field(keys.name, .string, .required)
            .field(keys.password, .string, .required)
            .field(keys.role, .string, .required)
            .unique(on: keys.username)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(scheme).delete()
    }
}

