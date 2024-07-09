// TelegramController.swift

import Foundation
import Hummingbird
import SwiftTelegramSdk

final class TelegramController {
    
    func addRoutes(to group: RouterGroup<some RequestContext>, actor: TGBotActor) {
        group.post("telegramWebHook") { req, context in
            let update: TGUpdate = try await req.decode(as: TGUpdate.self, context: context)
            Task {
                await actor.bot.dispatcher.process([update])
            }
            return Response(status: 200)
        }
    }
    
}
