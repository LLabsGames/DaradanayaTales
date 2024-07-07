//
//  configure.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import Foundation
import Hummingbird
import SwiftTelegramSdk

public func configure(_ app: some ApplicationProtocol) async throws {
    let tgApi: String = ProcessInfo.processInfo.environment["TG_API_Key"] ?? ""
    
    /// SET WEBHOOK CONNECTION
    // let bot: TGBot = try await .init(connectionType: .webhook(webHookURL: URL(string: "https://your_domain/telegramWebHook")!),
    //                                  dispatcher: nil,
    //                                  tgClient: URLSessionTGClient(),
    //                                  tgURI: TGBot.standardTGURL,
    //                                  botId: tgApi,
    //                                  log: app.logger)
    
    /// SET LONGPOLLING CONNECTION
    let bot: TGBot = try await .init(connectionType: .longpolling(limit: nil,
                                     timeout: nil, allowedUpdates: nil),
                                     dispatcher: nil, tgClient: AsyncHttpTGClient(),
                                     tgURI: TGBot.standardTGURL, botId: tgApi, log: app.logger)
    
    // set level of debug if you needed
    // bot.log.logLevel = .error
    await botActor.setBot(bot)
    await DefaultBotHandlers.addHandlers(bot: botActor.bot)
    try await botActor.bot.start()
}
