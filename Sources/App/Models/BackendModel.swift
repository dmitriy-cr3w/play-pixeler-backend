//
//  File.swift
//  
//
//  Created by Dmitriy Holovnia on 04.09.2024.
//

import Vapor
import Fluent

final class BackendModel: Model, Content, @unchecked Sendable {
    static let schema = Schema.backend.rawValue
    
    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.title) var title: String
    @Field(key: FieldKeys.link) var link: String
    @Field(key: FieldKeys.password) var password: String
    
    init() {}
    
    init(id: UUID? = UUID(), title: String, link: String, password: String) {
        self.id = id
        self.title = title
        self.link = link
        self.password = password
    }
}

extension BackendModel {
    enum FieldKeys {
        static var title: FieldKey { "title" }
        static var link: FieldKey { "link" }
        static var password: FieldKey { "password" }
    }
}
