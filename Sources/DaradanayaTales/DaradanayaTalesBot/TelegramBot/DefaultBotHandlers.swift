//
//  DefaultBotHandlers.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import SwiftTelegramSdk
import HummingbirdFluent
import Hummingbird

final class DefaultBotHandlers {
    
    static var routers = [String: TGRouter]()
    
    static func addHandlers(bot: TGBot, botName: TGBotName, fluent: Fluent) async {
        await defaultBaseHandler(bot: bot, botName: botName, fluent: fluent)
        await commandPingHandler(bot: bot)
        await commandShowButtonsHandler(bot: bot)
        await buttonsActionHandler(bot: bot)
        await messageHandler(bot: bot)
    }

    private static func defaultBaseHandler(bot: TGBot, botName: TGBotName, fluent: Fluent) async {
        await bot.dispatcher.add(TGBaseHandler({ update in
            guard let message = update.message else { return }
            let chatId = message.chat.id
            
            // Properties associated with request context
            var properties = [String: AnyObject]()
            
            let session: Session
            do {
                if let presentSession = try await Session.find(chatId, on: fluent.db()) {
                    session = presentSession
                } else {
                    //TODO: - Create a new session with default values
                    session = Session()
                    try await session.save(on: fluent.db())
                }
                
                // Fetching from database is expensive operation. Store the session
                // in properties to avoid fetching it again in handlers
                properties["session"] = session
                
                let router = routers[session.location.route]
                if let router = router {
                    try router.process(update: update, botName: botName, properties: properties)
                } else {
                    print("Warning: chat \(chatId) has invalid router: \(session.location.route)")
                }
                
                //let params = TGSendMessageParams(chatId: .chat(chatId), text: "TGBaseHandler for \(chatId), @\(session.name)")
                //try await bot.sendMessage(params: params)
            } catch {
                print(String(reflecting: error))
                bot.log.error("Failed to process update: \(String(reflecting: error))")
            }
        }))
    }

    private static func commandPingHandler(bot: TGBot) async {
        await bot.dispatcher.add(TGCommandHandler(commands: ["/ping"]) { update in
            try await update.message?.reply(text: "pong", bot: bot)
        })
    }

    private static func commandShowButtonsHandler(bot: TGBot) async {
        await bot.dispatcher.add(TGCommandHandler(commands: ["/show_buttons"]) { update in
            guard let userId = update.message?.from?.id else { fatalError("user id not found") }
            let buttons: [[TGInlineKeyboardButton]] = [
                [.init(text: "Button 1", callbackData: "press 1"), .init(text: "Button 2", callbackData: "press 2")]
            ]
            let keyboard = TGInlineKeyboardMarkup(inlineKeyboard: buttons)
            let params = TGSendMessageParams(chatId: .chat(userId), text: "Keyboard active", replyMarkup: .inlineKeyboardMarkup(keyboard))
            try await bot.sendMessage(params: params)
        })
    }

    private static func buttonsActionHandler(bot: TGBot) async {
        await bot.dispatcher.add(TGCallbackQueryHandler(pattern: "press 1") { update in
            bot.log.info("press 1")
            guard let userId = update.callbackQuery?.from.id else { fatalError("user id not found") }
            let params = TGAnswerCallbackQueryParams(callbackQueryId: update.callbackQuery?.id ?? "0", text: update.callbackQuery?.data ?? "data not exist")
            try await bot.answerCallbackQuery(params: params)
            try await bot.sendMessage(params: .init(chatId: .chat(userId), text: "press 1"))
        })

        await bot.dispatcher.add(TGCallbackQueryHandler(pattern: "press 2") { update in
            bot.log.info("press 2")
            guard let userId = update.callbackQuery?.from.id else { fatalError("user id not found") }
            let params = TGAnswerCallbackQueryParams(callbackQueryId: update.callbackQuery?.id ?? "0", text: update.callbackQuery?.data ?? "data not exist")
            try await bot.answerCallbackQuery(params: params)
            try await bot.sendMessage(params: .init(chatId: .chat(userId), text: "press 2"))
        })
    }
    
    private static func messageHandler(bot: TGBot) async {
        await bot.dispatcher.add(TGMessageHandler(filters: (.all && !.command.names(["/ping", "/show_buttons"]))) { update in
            let params = TGSendMessageParams(chatId: .chat(update.message!.chat.id), text: "Success")
            try await bot.sendMessage(params: params)
        })
    }
}
