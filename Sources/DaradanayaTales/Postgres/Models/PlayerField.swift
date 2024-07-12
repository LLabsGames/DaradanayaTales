//
//  PlayerField.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//


import FluentKit

final class Player: Fields, @unchecked Sendable {
    @Field(key: "race")
    var race: String

    @Field(key: "state")
    var state: String

    @Field(key: "nickname")
    var nickname: String

    @Field(key: "class")
    var playerClass: String

    init() { }

    init(race: String, state: String, nickname: String, playerClass: String) {
        self.race = race
        self.state = state
        self.nickname = nickname
        self.playerClass = playerClass
    }
}
