//
//  Session.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import FluentKit
import Foundation
import HummingbirdFluent
import Hummingbird

final class Session: Model, @unchecked Sendable {
    static let schema = "sessions"

    @ID(custom: "chat_id", generatedBy: .user)
    var id: Int64?

    @Group(key: "settings")
    var settings: Settings

    @Group(key: "location")
    var location: Location

    @Group(key: "player")
    var player: Player
    
    @Group(key: "techData")
    var techData: TechData

    init() {}

    init(id: Int64, settings: Settings = Settings(), location: Location = Location(), player: Player, techData: TechData = TechData()) {
        self.id = id
        self.settings = settings
        self.location = location
        self.player   = player
        self.techData = techData
    }
    
    func update(with session: Session) {
        self.settings = session.settings
        self.location = session.location
        self.player = session.player
    }
}

extension Session: ResponseCodable, Codable {}
