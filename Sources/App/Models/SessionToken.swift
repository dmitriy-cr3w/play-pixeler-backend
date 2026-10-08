//
//  File.swift
//  
//
//  Created by Dmitriy Holovnia on 21.12.2023.
//

import Foundation
import Fluent
import Vapor
@preconcurrency import JWT

struct SessionToken: Content, Authenticatable, JWTPayload {
    var expiration: ExpirationClaim
    var userId: UUID
    var payload: Payload

    init(userId: UUID, payload: Payload) {
        self.expiration = .init(value: .distantFuture)
        self.userId = userId
        self.payload = payload
    }

    init(user: UserModel, payload: Payload) throws {
        self.expiration = .init(value: .distantFuture)
        self.userId = try user.requireID()
        self.payload = payload
    }
    
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

struct Payload: Codable {
    var data: String?
}

struct WebPayloadData: Codable {
    var direction: String
    var oneSignal: String?
    var proxy: String?
}

struct ClientTokenReponse: Content {
    var token: String
}
