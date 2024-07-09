import FluentKit

struct CreateSessionsTableMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        return try await database.schema("sessions")
            .field("chat_id", .int64, .identifier(auto: false))
            .field("name", .string, .required)
            .field("coordinates_latitude", .double, .required)
            .field("coordinates_longitude", .double, .required)
            .unique(on: "name")
            .create()
    }

    func revert(on database: Database) async throws {
        return try await database.schema("sessions").delete()
    }
}
