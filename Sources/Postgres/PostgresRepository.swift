import Foundation
import Hummingbird
import PostgresNIO

struct PostgresRepository: DanayaRepository, Sendable {
    let client: PostgresClient
    let logger: Logger

    /// Create Todos table
    func createTable() async throws {
        do {
            try await self.client.query(
                """
                CREATE TABLE IF NOT EXISTS danaya (
                    "id" uuid PRIMARY KEY,
                    "title" text NOT NULL,
                    "order" integer,
                    "completed" boolean,
                    "url" text
                )
                """,
                logger: self.logger
            )
        } catch {
            self.logger.error("Error creating table: \(error)")
            print(String(reflecting: error))
            throw error
        }
    }

    /// Create todo.
    func create(title: String, order: Int?, urlPrefix: String) async throws -> Todo {
        let id = UUID()
        let url = urlPrefix + id.uuidString
        // The string interpolation is building a PostgresQuery with bindings and is safe from sql injection
        try await self.client.query(
            "INSERT INTO danaya (id, title, url, \"order\") VALUES (\(id), \(title), \(url), \(order));",
            logger: self.logger
        )
        return Todo(id: id, title: title, order: order, url: url, completed: nil)
    }

    /// Get todo.
    func get(id: UUID) async throws -> Todo? {
        // The string interpolation is building a PostgresQuery with bindings and is safe from sql injection
        let stream = try await self.client.query(
            """
            SELECT "id", "title", "order", "url", "completed" FROM danaya WHERE "id" = \(id)
            """,
            logger: self.logger
        )
        for try await(id, title, order, url, completed) in stream.decode((UUID, String, Int?, String, Bool?).self, context: .default) {
            return Todo(id: id, title: title, order: order, url: url, completed: completed)
        }
        return nil
    }

    /// List all danaya
    func list() async throws -> [Todo] {
        let stream = try await self.client.query(
            """
            SELECT "id", "title", "order", "url", "completed" FROM danaya
            """,
            logger: self.logger
        )
        var danaya: [Todo] = []
        for try await(id, title, order, url, completed) in stream.decode((UUID, String, Int?, String, Bool?).self, context: .default) {
            let todo = Todo(id: id, title: title, order: order, url: url, completed: completed)
            danaya.append(todo)
        }
        return danaya
    }

    /// Update todo. Returns updated todo if successful
    func update(id: UUID, title: String?, order: Int?, completed: Bool?) async throws -> Todo? {
        let query: PostgresQuery?
        // UPDATE query. Work out query based on whick values are not nil
        // The string interpolation is building a PostgresQuery with bindings and is safe from sql injection
        if let title {
            if let order {
                if let completed {
                    query = "UPDATE danaya SET title = \(title), order = \(order), completed = \(completed) WHERE id = \(id)"
                } else {
                    query = "UPDATE danaya SET title = \(title), order = \(order) WHERE id = \(id)"
                }
            } else {
                if let completed {
                    query = "UPDATE danaya SET title = \(title), completed = \(completed) WHERE id = \(id)"
                } else {
                    query = "UPDATE danaya SET title = \(title) WHERE id = \(id)"
                }
            }
        } else {
            if let order {
                if let completed {
                    query = "UPDATE danaya SET order = \(order), completed = \(completed) WHERE id = \(id)"
                } else {
                    query = "UPDATE danaya SET order = \(order) WHERE id = \(id)"
                }
            } else {
                if let completed {
                    query = "UPDATE danaya SET completed = \(completed) WHERE id = \(id)"
                } else {
                    query = nil
                }
            }
        }
        if let query {
            _ = try await self.client.query(query, logger: self.logger)
        }

        // SELECT so I can get the full details of the TODO back
        // The string interpolation is building a PostgresQuery with bindings and is safe from sql injection
        let stream = try await self.client.query(
            """
            SELECT "id", "title", "order", "url", "completed" FROM danaya WHERE "id" = \(id)
            """,
            logger: self.logger
        )
        for try await(id, title, order, url, completed) in stream.decode((UUID, String, Int?, String, Bool?).self, context: .default) {
            return Todo(id: id, title: title, order: order, url: url, completed: completed)
        }
        return nil
    }

    /// Delete todo. Returns true if successful
    func delete(id: UUID) async throws -> Bool {
        // The string interpolation is building a PostgresQuery with bindings and is safe from sql injection
        let selectStream = try await self.client.query(
            """
            SELECT "id" FROM danaya WHERE "id" = \(id)
            """,
            logger: self.logger
        )
        // if we didn't find the item with this id then return false
        if try await selectStream.decode(UUID.self, context: .default).first(where: { _ in true }) == nil {
            return false
        }
        _ = try await self.client.query("DELETE FROM danaya WHERE id = \(id);", logger: self.logger)
        return true
    }

    /// Delete all danaya
    func deleteAll() async throws {
        try await self.client.query("DELETE FROM danaya;", logger: self.logger)
    }
}
