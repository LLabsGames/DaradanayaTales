//
//  TelegramController.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import Foundation
import Hummingbird
import SwiftTelegramSdk

// MARK: - TelegramController

final class TelegramController {
    func addRoutes(to group: RouterGroup<some RequestContext>, actor: TGBotActor) {
        group.post("telegramWebHook") { req, context in
            let update = try await req.decode(as: TGUpdate.self, context: context)
            await actor.bot.dispatcher.process([update])
            return Response(status: .ok)
        }
    }
}
