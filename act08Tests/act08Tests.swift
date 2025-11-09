//
//  act08Tests.swift
//  act08Tests
//
//  Created by Alumno on 24/10/25.
//

import Testing
import Foundation
@testable import act08

struct act08Tests {

    @Test func testContentModelDecoding() async throws {
        let json = """
        {
            "content_id": 1,
            "name": "Test Content",
            "details": "Test Details",
            "url": "https://example.com",
            "resourceType": "video",
            "transcript": "Test transcript",
            "course": 101,
            "level": 1,
            "lection": 5,
            "resource": 10,
            "createdAt": "2025-11-08T12:00:00.000Z",
            "updatedAt": "2025-11-08T12:00:00.000Z",
            "deletedAt": null
        }
        """

        let decoder = ISO8601DateCoder.decoder()
        let data = json.data(using: .utf8)!
        let content = try decoder.decode(Content.self, from: data)

        #expect(content.name == "Test Content")
        #expect(content.details == "Test Details")
        #expect(content.resourceType == .video)
        #expect(content.course == 101)
        #expect(content.transcript == "Test transcript")
    }

    @Test func testContentCreateEncoding() async throws {
        let contentCreate = ContentCreate(
            name: "New Content",
            details: "New Details",
            url: "https://example.com/new",
            resourceType: .article,
            transcript: nil,
            course: 200,
            level: 2,
            lection: 10,
            resource: 20
        )

        let encoder = ISO8601DateCoder.encoder()
        let data = try encoder.encode(contentCreate)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "New Content")
        #expect(json["resourceType"] as? String == "article")
        #expect(json["course"] as? Int == 200)
    }
}
