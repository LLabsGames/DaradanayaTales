//
//  TGBotActor.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import SwiftTelegramSdk

// MARK: - TGBotActor

actor TGBotActor {
    private var _bot: TGBot!

    var bot: TGBot {
        self._bot
    }

    func setBot(_ bot: TGBot) {
        self._bot = bot
    }
}
