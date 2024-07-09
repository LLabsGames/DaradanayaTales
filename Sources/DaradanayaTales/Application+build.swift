//
//  Application+build.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import FluentPostgresDriver
import Hummingbird
import HummingbirdFluent
import Logging
import SwiftTelegramSdk

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable.
/// Any variables added here also have to be added to `App` in App.swift and
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
}

public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let logger = {
        var logger = Logger(label: "DaradanayaTales")
        logger.logLevel = arguments.logLevel ?? .info
        return logger
    }()
    
    let router = Router()
    
    // Add health route
    router.get("/health") { _,_ -> HTTPResponse.Status in
        return .ok
    }
    
    // Add / route
    router.get("/") { _,_ in
        return "Hello, Stranger! 🌍"
    }
    
    let fluent = Fluent(logger: logger)
    let env = try await Environment.dotEnv("/Users/maximlanskoy/Downloads/Hummingbird_tutorial-main/DaradanayaTales/.env")
    
    // Configure database
    let postgreSQLConfig = SQLPostgresConfiguration(hostname: env.get("POSTGRES_HOST") ?? "localhost",
                                                    port: env.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
                                                    username: env.get("POSTGRES_USER") ?? "username",
                                                    password: env.get("POSTGRES_PASSWORD") ?? "password",
                                                    database: env.get("POSTGRES_DB") ?? "database",
                                                    tls: .disable) /*.prefer(try .init(configuration: .clientDefault)))*/
    
    fluent.databases.use(.postgres(configuration: postgreSQLConfig, sqlLogLevel: .warning), as: .psql)
    
    await fluent.migrations.add(CreateSessionsTableMigration())
    
    // Migration
    try await fluent.migrate()
    
    // Add controller
    SessionsController(fluent: fluent).addRoutes(to: router.group("api/v1/sessions"))
    
    // Create application
    var app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "DaradanayaTales"
        ),
        logger: logger
    )
    
    // Create Telegram bot actor
    let botActor = TGBotActor()
    let key = env.get("TG_API_KEY") ?? "XXXXXXXXXX:YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
    try await configureTelegramBot(app, actor: botActor, key: key, fluent: fluent)
    
    app.addServices(fluent)
    return app
}

func configureTelegramBot(_ app: some ApplicationProtocol, actor: TGBotActor, key: String, fluent: Fluent) async throws {
    guard !key.isEmpty else {
        app.logger.critical("Telegram API Key not found in environment variables or command line arguments.")
        throw ConfigurationError.missingAPIKey
    }

    let bot = try await TGBot(
        connectionType: .longpolling(limit: nil, timeout: nil, allowedUpdates: nil),
        dispatcher: nil,
        tgClient: AsyncHttpTGClient(),
        tgURI: TGBot.standardTGURL,
        botId: key,
        log: app.logger
    )
    
    await actor.setBot(bot)
    await DefaultBotHandlers.addHandlers(bot: actor.bot, fluent: fluent)
    try await actor.bot.start()
}

enum ConfigurationError: Error {
    case missingAPIKey
}
