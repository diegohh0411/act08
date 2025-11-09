//
//  Content.swift
//  act08
//
//  Created by diegoh on 11/08/25.
//

import Foundation

enum ResourceType: String, Codable, CaseIterable {
    case video = "video"
    case article = "article"
    case podcast = "podcast"
    case file = "file"
}

struct Content: Codable, Identifiable {
    var id: Int { content_id }
    let content_id: Int
    var name: String
    var details: String?
    var url: String
    var resourceType: ResourceType
    var transcript: String?
    var course: Int
    var level: Int
    var lection: Int
    var resource: Int
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case content_id
        case name
        case details
        case url
        case resourceType
        case transcript
        case course
        case level
        case lection
        case resource
        case createdAt
        case updatedAt
        case deletedAt
    }
}

struct ContentCreate: Codable {
    var name: String
    var details: String
    var url: String
    var type: ResourceType
    var transcript: String

    enum CodingKeys: String, CodingKey {
        case name
        case details
        case url
        case type
        case transcript
    }
}

struct ContentUpdate: Codable {
    var name: String?
    var details: String?
    var url: String?
    var type: ResourceType?
    var transcript: String?

    enum CodingKeys: String, CodingKey {
        case name
        case details
        case url
        case type
        case transcript
    }
}
