//
//  File.swift
//
//
//  Created by Dmitriy Holovnia on 21.12.2023.
//

import Foundation
import Vapor
import Fluent


enum Role: String, Codable {
    case admin, anonymous
}

final class UserModel: Model, Content, @unchecked Sendable {
    static let schema = Schema.users.rawValue
    
    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.name) var name: String
    @Field(key: FieldKeys.username) var username: String
    @Field(key: FieldKeys.password) var password: String
    @Enum(key: FieldKeys.role) var role: Role
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String, password: String, role: Role) {
        self.id = id
        self.name = name
        self.username = username
        self.password = password
        self.role = role
    }
}


// MARK: - FieldKeys
extension UserModel {
    enum FieldKeys {
        static var name: FieldKey { "name" }
        static var username: FieldKey { "username" }
        static var password: FieldKey { "password" }
        static var role: FieldKey { "role" }
    }
}

// MARK: - Public Model
extension UserModel {
    final class Public: Content {
        let id: UUID?
        let name: String
        let username: String
        let role: Role
        
        init(id: UUID? = nil, name: String, username: String, role: Role) {
            self.id = id
            self.name = name
            self.username = username
            self.role = role
        }
    }
    
    func convertToPublic() -> UserModel.Public {
        UserModel.Public(id: id, name: name, username: username, role: role)
    }
}

//MARK: - Authentication
extension UserModel: Authenticatable {}
extension UserModel: ModelAuthenticatable {
    static var usernameKey: KeyPath<UserModel, Field<String>> {
        \UserModel.$username
    }
    
    static var passwordHashKey: KeyPath<UserModel, Field<String>> {
        \UserModel.$password
    }
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

