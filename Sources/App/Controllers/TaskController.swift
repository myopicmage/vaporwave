import Fluent
import Vapor

struct TaskController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let tasks =
      routes
      .grouped(UserToken.authenticator())
      .grouped(UserToken.guardMiddleware())
      .grouped("tasks")

    tasks.get(use: index)
    tasks.post(use: create)

    tasks.group(":taskID") { task in
      task.get(use: get)
      task.delete(use: delete)
      task.patch(use: patch)
    }
  }

  func index(req: Request) async throws -> [Task] {
    try await Task.query(on: req.db).all()
  }

  func get(req: Request) async throws -> Task {
    guard let task = try await Task.find(req.parameters.get("taskID"), on: req.db) else {
      throw Abort(.notFound)
    }

    try await task.$category.load(on: req.db)

    return task
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

  func patch(req: Request) async throws -> Task {
    guard let task = try await Task.find(req.parameters.get("taskID"), on: req.db) else {
      throw Abort(.notFound)
    }

    let patch = try req.content.decode(Task.TaskDTO.self)

    task.task = patch.task ?? task.task
    task.due = patch.due ?? task.due
    task.status = patch.status ?? task.status
    task.notes = patch.notes ?? task.notes
    task.priority = patch.priority ?? task.priority
    task.category = patch.category ?? task.category

    try await task.save(on: req.db)

    return task
  }
}
