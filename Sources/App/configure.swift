import Vapor
import JWT
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver
import Leaf



func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.jwt.signers.use(.hs256(key: "2495732C-C9B4-48E2-B4AB-FF860DE59BC1"))
    
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 80
    
    // Database
    if let databaseURL = Environment.get("DATABASE_URL") {
        var tlsConfig: TLSConfiguration = .makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        let nioSSLContext = try NIOSSLContext(configuration: tlsConfig)

        var postgresConfig = try SQLPostgresConfiguration(url: databaseURL)
        postgresConfig.coreConfiguration.tls = .require(nioSSLContext)

        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    } else {
        app.databases.use(.sqlite(.memory), as: .sqlite)
    }
    
    // Migrations
    app.migrations.add(CreateBackendModel())
    app.migrations.add(CreateLinkModel())
    app.migrations.add(CreateUserModel())
    
    // Seeds
    app.migrations.add(CreateUserSeed())
    
    app.views.use(.leaf)
    try await app.autoMigrate().get()
    try routes(app)
}
