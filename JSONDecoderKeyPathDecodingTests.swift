//  JSONDecoderKeyPathDecodingTests.swift

import XCTest
@testable import TransportCore

final class JSONDecoderKeyPathDecodingTests: XCTestCase {

  func testDecodingWithKeyPath() throws {
    // given
    let keyPathJsonDecoder = JSONDecoder()

    // when
    let post = try keyPathJsonDecoder.decode(Post.self, from: jsonData, keyPath: "post")
    // then
    XCTAssertEqual(post.title, "Hello")

    // when
    let postNested = try keyPathJsonDecoder.decode(Post.self, from: jsonData, keyPath: "nested.post")
    // then
    XCTAssertEqual(postNested.title, "What is this")

    // when
    let postEmbeded = try keyPathJsonDecoder.decode(Post.self, from: jsonData, keyPath: "nested.post.embedded_post")
    // then
    XCTAssertEqual(postEmbeded.title, "Embedded Post")

    // when
    var singleValue = try keyPathJsonDecoder.decode(String.self, from: jsonData, keyPath: "post.detail")
    // then
    XCTAssertEqual(singleValue, "My post, hello!")

    // when
    singleValue = try keyPathJsonDecoder.decode(String.self, from: jsonData, keyPath: "nested.post.detail")
    // then
    XCTAssertEqual(singleValue, "The nest seems to work")

    // when
    singleValue = try keyPathJsonDecoder.decode(String.self, from: jsonData, keyPath: "nested.post.embedded_post.detail")
    // then
    XCTAssertEqual(singleValue, "Embedded post also work")
  }

  private let jsonData = """
{
    "post": {
        "title": "Hello",
        "detail": "My post, hello!",
        "likes": 20
    },
    "something": "...",
    "nested": {
        "something": "...",
        "post": {
            "title": "What is this",
            "detail": "The nest seems to work",
            "likes": 14,
            "embedded_post": {
                "title": "Embedded Post",
                "detail": "Embedded post also work",
                "likes": 100
            }
        }
    }
}
""".data(using: .utf8)!

  private struct Post: Decodable {
    let title: String
    let detail: String
    let likes: Int
  }
}
