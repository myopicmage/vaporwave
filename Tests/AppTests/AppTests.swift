import XCTVapor

@testable import App

final class AppTests: XCTestCase {
  let app: Application = Application(.testing)

  override func setUp() async throws {
    try await configure(app)
  }

  override func tearDown() async throws {
    app.shutdown()
  }

  func testHelloWorld() async throws {
    try app.test(.GET, "up") { res in
      XCTAssertEqual(res.status, .ok)
    }
  }

  func test401() async throws {
    let app: Application = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)

    try app.test(.POST, "tasks") { res in
      XCTAssertEqual(res.status, .unauthorized)
    }
  }
}
