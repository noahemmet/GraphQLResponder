import XCTest
import Graphiti
@testable import GraphQLResponder

let schema = try! Schema<NoRoot, Request> { schema in
    try schema.query { query in
        try query.field(name: "hello", type: String.self) { _, _, request, _ in
            XCTAssertEqual(request.method, .get)
            XCTAssertEqual(request.path, "/graphql")
            return "world"
        }
    }
}

let graphql = GraphQLResponder(schema: schema, rootValue: noRootValue)

class GraphQLResponderTests : XCTestCase {
    func testHello() throws {
        let query: Axis.Map = [
            "query": "{ hello }"
        ]

        let expected: Axis.Map = [
            "data": [
                "hello": "world"
            ]
        ]

        let request = Request(url: "/graphql", content: query)!
        let response = try graphql.respond(to: request)
        XCTAssertEqual(response.content, expected)
    }

    func testBoyhowdy() throws {
        let query: Axis.Map = [
            "query": "{ boyhowdy }"
        ]

        let expected: Axis.Map = [
            "errors": [
                [
                    "message": "Cannot query field \"boyhowdy\" on type \"Query\".",
                    "locations": [["line": 1, "column": 3]]
                ]
            ]
        ]

        let request = Request(url: "/graphql", content: query)!
        let response = try graphql.respond(to: request)
        XCTAssertEqual(response.content, expected)
    }

    func testNoRequestContext() throws {
        let schema = try Schema<NoRoot, NoContext> { schema in
            try schema.query { query in
                try query.field(name: "hello", type: String.self) { _, _, _, _ in
                    return "world"
                }
            }
        }

        let graphql = GraphQLResponder(schema: schema, rootValue: noRootValue)

        let query: Axis.Map = [
            "query": "{ boyhowdy }"
        ]

        let expected: Axis.Map = [
            "errors": [
                [
                    "message": "Cannot query field \"boyhowdy\" on type \"Query\".",
                    "locations": [["line": 1, "column": 3]]
                ]
            ]
        ]

        let request = Request(url: "/graphql", content: query)!
        let response = try graphql.respond(to: request)
        XCTAssertEqual(response.content, expected)
    }

    static var allTests : [(String, (GraphQLResponderTests) -> () throws -> Void)] {
        return [
            ("testHello", testHello),
            ("testBoyhowdy", testBoyhowdy),
        ]
    }
}
