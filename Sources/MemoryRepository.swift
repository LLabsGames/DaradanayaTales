import Foundation

/// Concrete implementation of `TodoRepository` that stores everything in memory
actor MemoryRepository: DanayaRepository {
    var danaya: [UUID: Todo]

    init() {
        self.danaya = [:]
    }

    /// Create todo.
    func create(title: String, order: Int?, urlPrefix: String) async throws -> Todo {
        let id = UUID()
        let url = urlPrefix + id.uuidString
        let todo = Todo(id: id, title: title, order: order, url: url, completed: false)
        self.danaya[id] = todo
        return todo
    }

    /// Get todo
    func get(id: UUID) async throws -> Todo? {
        return self.danaya[id]
    }

    /// List all danaya
    func list() async throws -> [Todo] {
        return self.danaya.values.map { $0 }
    }

    /// Update todo. Returns updated todo if successful
    func update(id: UUID, title: String?, order: Int?, completed: Bool?) async throws -> Todo? {
        if var todo = self.danaya[id] {
            if let title {
                todo.title = title
            }
            if let order {
                todo.order = order
            }
            if let completed {
                todo.completed = completed
            }
            self.danaya[id] = todo
            return todo
        }
        return nil
    }

    /// Delete todo. Returns true if successful
    func delete(id: UUID) async throws -> Bool {
        if self.danaya[id] != nil {
            self.danaya[id] = nil
            return true
        }
        return false
    }

    /// Delete all danaya
    func deleteAll() async throws {
        self.danaya = [:]
    }
}
