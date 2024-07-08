import Foundation

/// Interface for storing and editing danaya
protocol DanayaRepository {
    /// Create todo.
    func create(title: String, order: Int?, urlPrefix: String) async throws -> Todo
    /// Get todo
    func get(id: UUID) async throws -> Todo?
    /// List all danaya
    func list() async throws -> [Todo]
    /// Update todo. Returns updated todo if successful
    func update(id: UUID, title: String?, order: Int?, completed: Bool?) async throws -> Todo?
    /// Delete todo. Returns true if successful
    func delete(id: UUID) async throws -> Bool
    /// Delete all danaya
    func deleteAll() async throws
}
