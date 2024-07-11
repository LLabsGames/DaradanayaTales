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

    init() {}

    init(id: Int64, settings: Settings, location: Location, player: Player) {
        self.id = id
        self.settings = settings
        self.location = location
        self.player = player
    }
    
    func update(with session: Session) {
        self.settings = session.settings
        self.location = session.location
        self.player = session.player
    }
}

extension Session: ResponseCodable, Codable {}

final class Player: Fields, @unchecked Sendable {
    @Field(key: "race")
    var race: String

    @Field(key: "state")
    var state: String

    @Field(key: "nickname")
    var nickname: String

    @Field(key: "class")
    var playerClass: String

    // Other player attributes can be added here...

    init() { }

    init(race: String, state: String, nickname: String, playerClass: String) {
        self.race = race
        self.state = state
        self.nickname = nickname
        self.playerClass = playerClass
    }
}

final class Location: Fields, @unchecked Sendable {
    @Field(key: "universe")
    var universe: String

    @Field(key: "galaxy")
    var galaxy: String

    @Field(key: "planet")
    var planet: String

    @Field(key: "route")
    var route: String

    init() { }

    init(universe: String, galaxy: String, planet: String, route: String) {
        self.universe = universe
        self.galaxy = galaxy
        self.planet = planet
        self.route = route
    }
}

final class Settings: Fields, @unchecked Sendable {
    @Field(key: "language")
    var language: String

    @Field(key: "mapsize")
    var mapsize: String

    @Field(key: "profilesize")
    var profilesize: String

    init() { }

    init(language: String, mapsize: String, profilesize: String) {
        self.language = language
        self.mapsize = mapsize
        self.profilesize = profilesize
    }
}
