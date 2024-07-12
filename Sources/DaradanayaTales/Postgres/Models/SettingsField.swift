//
//  SettingsField.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import FluentKit

final class Settings: Fields, @unchecked Sendable {
    @Field(key: "language")
    var language: String

    @Field(key: "emojiMapsize")
    var emojiMapsize: Int

    @Field(key: "profilesize")
    var profilesize: ProfileSize

    init() { }

    init(language: String = "en", emojiMapsize: Int = 9, profilesize: ProfileSize) {
        self.language = language
        self.emojiMapsize = emojiMapsize
        self.profilesize = profilesize
    }
}

enum ProfileSize: String, Codable {    
    case small
    case compact
    case full
}
