//
//  CreateSessionsTableMigration.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import FluentKit

struct CreateSessionsTableMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        return try await database.schema("sessions")
            .field("chat_id", .int64, .identifier(auto: false))
            .field("settings_language", .string, .required)
            .field("settings_emojiMapsize", .int, .required)
            .field("settings_profilesize", .string, .required)
            .field("location_universe", .string, .required)
            .field("location_galaxy", .string, .required)
            .field("location_planet", .string, .required)
            .field("location_route", .string, .required)
            .field("location_coordinates_x", .int)
            .field("location_coordinates_y", .int)
            .field("player_race", .string, .required)
            .field("player_state", .string, .required)
            .field("player_nickname", .string, .required)
            .field("player_class", .string, .required)
            .field("techData_referralFrom", .int64)
            .field("techData_referrals", .array(of: .int64), .required)
            .create()
    }

    func revert(on database: Database) async throws {
        return try await database.schema("sessions").delete()
    }
}
