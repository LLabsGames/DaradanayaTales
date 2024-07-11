//
//  RoutedBotHandlers.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//


import SwiftTelegramSdk
import HummingbirdFluent

final class RoutedBotHandlers {
    
    static var routers = [String: TGRouter]()
    
    static func addHandlers(bot: TGBot, botName: TGBotName, fluent: Fluent) async {
        await bot.dispatcher.add(TGBaseHandler({ update in
            guard let message = update.message else { return }
            let chatId = message.chat.id
            let nickName = message.from?.username ?? message.from?.firstName
            
            // Properties associated with request context
            var properties = [String: AnyObject]()
            
            let session: Session
            do {
                if let presentSession = try await Session.find(chatId, on: fluent.db()) {
                    session = presentSession
                } else {
                    let location = Location(universe: "Euclid", galaxy: "IO-1", planet: "Kassiopea", route: "main")
                    let settings = Settings(language: "en", emojiMapsize: 9, profilesize: "full")
                    let  player  = Player(race: "Elf", state: "Male", nickname: nickName ?? "Daya", playerClass: "Universal")
                    session = Session(id: chatId, settings: settings, location: location, player: player)
                    try await session.save(on: fluent.db())
                }
                
                // Fetching from database is expensive operation. Store the session
                // in properties to avoid fetching it again in handlers
                properties["session"] = session
                
                let router = routers[session.location.route]
                if let router = router {
                    try router.process(update: update, botName: botName, properties: properties)
                } else {
                    bot.log.warning("Warning: chat \(chatId) has invalid router: \(session.location.route)")
                }
                
                //let params = TGSendMessageParams(chatId: .chat(chatId), text: "TGBaseHandler for \(chatId), @\(session.name)")
                //try await bot.sendMessage(params: params)
            } catch {
                print(String(reflecting: error))
                bot.log.error("Failed to process update: \(String(reflecting: error))")
            }
        }))
    }
}
