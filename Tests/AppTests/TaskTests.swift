import XCTVapor

@testable import App

final class TaskTests: XCTestCase {
  let app: Application = Application(.testing)
  var token: String = ""

  override func setUp() async throws {
    try await configure(app)

    guard let username = Environment.get("TESTING_USER"),
      let password = Environment.get("TESTING_PASSWORD")
    else {
      throw "You must specify a username and password"
    }

    try app.test(.POST, "auth/login") { req in
      try req.content.encode([
        "username": username,
        "password": password,
      ])
    } afterResponse: { res in
      let token = try res.content.decode(ClientTokenResponse.self)

      self.token = token.token
    }
  }

  override func tearDown() {
    app.shutdown()
  }

  func testGetTasks() throws {
    try app.test(.GET, "tasks") { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: self.token)
    } afterResponse: { res in
      XCTAssertEqual(res.status, .ok)
      app.logger.info("Returned: \(res.body.string)")
      XCTAssertNotNil(res.body.string)
    }
  }

  func testAddTask() throws {
    let task = Task(task: "do a thing")

    try app.test(.POST, "tasks") { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: self.token)
      try req.content.encode(task)
    } afterResponse: { res in
      XCTAssertEqual(res.status, .ok)
      app.logger.info("Returned: \(res.body.string)")
      XCTAssertNotNil(res.body.string)

      let newTask = try res.content.decode(Task.self)

      XCTAssertEqual(newTask.task, task.task)

      let taskID = try newTask.requireID()

      try app.test(.DELETE, "tasks/\(taskID)") { req in
        req.headers.bearerAuthorization = BearerAuthorization(token: self.token)
      } afterResponse: { res in
        XCTAssertEqual(res.status, .noContent)
      }
    }
  }
}
