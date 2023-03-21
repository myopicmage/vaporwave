import Fluent
import Vapor

struct TaskController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tasks = routes.grouped("tasks")

        tasks.get(use: index)
        tasks.post(use: create)

        tasks.group(":taskID") { task in
            task.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [Task] {
        try await Task.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Task {
        let task = try req.content.decode(Task.self)

        try await task.save(on: req.db)

        return task
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let task = try await Task.find(req.parameters.get("taskID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await task.delete(on: req.db)

        return .noContent
    }
}
