//
//  DanayaConfiguration.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import Logging
import Foundation
import Hummingbird
import SwiftTelegramSdk

// MARK: - Configuration

func configure(_ app: some ApplicationProtocol, logger: Logger, actor botActor: TGBotActor) async throws {
    // Fetch API key from command line arguments or environment variables
    let tgApi: String
    if CommandLine.arguments.count > 1 {
        tgApi = CommandLine.arguments[1]
    } else {
        tgApi = ProcessInfo.processInfo.environment["TG_API_Key"] ?? ""
    }
    
    guard !tgApi.isEmpty else {
        logger.critical("Telegram API Key not found in environment variables or command line arguments.")
        throw ConfigurationError.missingAPIKey
    }

    let bot = try await TGBot(
        connectionType: .longpolling(limit: nil, timeout: nil, allowedUpdates: nil),
        dispatcher: nil,
        tgClient: AsyncHttpTGClient(),
        tgURI: TGBot.standardTGURL,
        botId: tgApi,
        log: app.logger
    )
    
    await botActor.setBot(bot)
    await DefaultBotHandlers.addHandlers(bot: botActor.bot)
    try await botActor.bot.start()
}

enum ConfigurationError: Error {
    case missingAPIKey
}
