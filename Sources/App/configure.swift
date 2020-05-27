import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let config = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )
    
    app.middleware.use(CORSMiddleware(configuration: config))
    app.middleware.use(ErrorMiddleware.default(environment: .development))
    app.passwords.use(.bcrypt)
    app.migrations.add(CreateStoredUser())
    app.databases.use(
        .postgres(
            hostname: "127.0.0.1",
            username: "vapor",
            password: "password",
            database: "vapor"), as: .psql
    )
    
    try routes(app)
}
