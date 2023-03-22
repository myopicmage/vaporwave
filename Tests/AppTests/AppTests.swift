@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testHelloWorld() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }

    func test401() async throws {
        let app: Application = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try app.test(.POST, "tasks") { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }

    // func testRegister() async throws {
    //     let app: Application = Application(.testing)
    //     defer { app.shutdown() }
    //     try await configure(app)

    //     try app.test(.POST, "auth/register") { req in
    //         try req.content.encode(User.Create(username: "testme", password: "testmetestmetestme", confirmPassword: "testmetestmetestme"))
    //     } afterResponse: { res in
    //         XCTAssertEqual(res.status, .badRequest)
    //     }
    // }

    func testGetTasks() async throws {
        let app: Application = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try app.test(.POST, "auth/login") { req in
            try req.content.encode([
                "username": "testme",
                "password": "testmetestmetestme"
            ])
        } afterResponse: { res in
            let token = try res.content.decode(ClientTokenResponse.self)

            try app.test(.GET, "tasks") { req in
                req.headers.add(name: .authorization, value: "Bearer \(token.token)")
            } afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
                app.logger.info("Returned: \(res.body.string)")
                XCTAssertNotNil(res.body.string)
            }
        }
    }

    func testAddTask() async throws {
        let app: Application = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try app.test(.POST, "auth/login") { req in
            try req.content.encode([
                "username": "testme",
                "password": "testmetestmetestme"
            ])
        } afterResponse: { res in
            let token = try res.content.decode(ClientTokenResponse.self)

            try app.test(.POST, "tasks") { req in
                req.headers.add(name: .authorization, value: "Bearer \(token.token)")
                try req.content.encode(Task(task: "do a thing"))
            } afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
                app.logger.info("Returned: \(res.body.string)")
                XCTAssertNotNil(res.body.string)
            }
        }
    }
}
