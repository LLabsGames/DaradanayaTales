//
//  main.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import SwiftTelegramSdk
import Hummingbird
import Logging

var logger = Logger(label: "DaradanayaBot")
logger.logLevel = .debug

let router = Router()
router.middlewares.add(LogRequestsMiddleware(.info))
TelegramController().addRoutes(to: router.group("tgbot"))

let app = Application(router: router)
let botActor: TGBotActor = .init()

try await configure(app)
try await app.runService()
