//
//  File.swift
//  
//
//  Created by Dmitriy Holovnia on 21.12.2023.
//

import Foundation
import Vapor

struct CheckAdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        return try await next.respond(to: request)
    }
}
