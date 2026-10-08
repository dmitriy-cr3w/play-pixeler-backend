//
//  File.swift
//  
//
//  Created by Dmitriy Holovnia on 21.12.2023.
//

import Foundation
import Vapor
import Fluent

struct CreateUserSeed: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
        let password = Environment.get("ADMIN_PASSWORD") ?? StaticValues.password
        let admin = try UserModel(name: "Dmitriy", username: "admin", password: Bcrypt.hash(password), role: .admin)
        try await admin.save(on: database)
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await UserModel.query(on: database)
            .filter(\.$role == .admin )
            .delete()
    }
}
