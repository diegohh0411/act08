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

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
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

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(contentCreate)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "New Content")
        #expect(json["resourceType"] as? String == "article")
        #expect(json["course"] as? Int == 200)
    }

    @Test func testResourceTypeEnum() async throws {
        #expect(ResourceType.video.rawValue == "video")
        #expect(ResourceType.article.rawValue == "article")
        #expect(ResourceType.podcast.rawValue == "podcast")
        #expect(ResourceType.file.rawValue == "file")
        #expect(ResourceType.allCases.count == 4)
    }

    @Test func testApiErrorMessages() async throws {
        let networkError = ApiError.networkError("Connection failed")
        #expect(networkError.localizedDescription.contains("Network error"))

        let badRequest = ApiError.badRequest("Invalid data")
        #expect(badRequest.localizedDescription.contains("Bad request"))

        let validationError = ApiError.unprocessableEntity("Missing fields")
        #expect(validationError.localizedDescription.contains("Validation error"))
    }

    @Test func testContentViewModelValidation() async throws {
        await MainActor.run {
            let viewModel = ContentViewModel()

            Task {
                let result = await viewModel.createContent(
                    name: "",
                    details: "Details",
                    url: "https://example.com",
                    resourceType: .video,
                    transcript: nil,
                    course: 1,
                    level: 1,
                    lection: 1,
                    resource: 1
                )

                #expect(result == false)
                #expect(viewModel.errorMessage == "Name is required")
            }
        }
    }

    @Test func testContentViewModelValidationDetails() async throws {
        await MainActor.run {
            let viewModel = ContentViewModel()

            Task {
                let result = await viewModel.createContent(
                    name: "Test",
                    details: "   ",
                    url: "https://example.com",
                    resourceType: .video,
                    transcript: nil,
                    course: 1,
                    level: 1,
                    lection: 1,
                    resource: 1
                )

                #expect(result == false)
                #expect(viewModel.errorMessage == "Details is required")
            }
        }
    }

    @Test func testContentViewModelValidationURL() async throws {
        await MainActor.run {
            let viewModel = ContentViewModel()

            Task {
                let result = await viewModel.createContent(
                    name: "Test",
                    details: "Details",
                    url: "",
                    resourceType: .video,
                    transcript: nil,
                    course: 1,
                    level: 1,
                    lection: 1,
                    resource: 1
                )

                #expect(result == false)
                #expect(viewModel.errorMessage == "URL is required")
            }
        }
    }

    @Test func testContentSorting() async throws {
        let dateFormatter = ISO8601DateFormatter()
        let oldDate = dateFormatter.date(from: "2025-01-01T12:00:00.000Z")!
        let newDate = dateFormatter.date(from: "2025-11-08T12:00:00.000Z")!

        let oldContent = Content(
            content_id: 1,
            name: "Old",
            details: "Old content",
            url: "https://old.com",
            resourceType: .video,
            transcript: nil,
            course: 1,
            level: 1,
            lection: 1,
            resource: 1,
            createdAt: oldDate,
            updatedAt: oldDate,
            deletedAt: nil
        )

        let newContent = Content(
            content_id: 2,
            name: "New",
            details: "New content",
            url: "https://new.com",
            resourceType: .video,
            transcript: nil,
            course: 2,
            level: 2,
            lection: 2,
            resource: 2,
            createdAt: newDate,
            updatedAt: newDate,
            deletedAt: nil
        )

        let contents = [oldContent, newContent].sorted { $0.createdAt > $1.createdAt }

        #expect(contents[0].content_id == 2)
        #expect(contents[1].content_id == 1)
    }
}
