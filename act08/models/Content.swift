//
//  Content.swift
//  act08
//
//  Created by diegoh on 11/08/25.
//

import Foundation

struct Content: Codable, Identifiable {
    var id: Int { content_id }
    let content_id: Int
    var name: String
    var details: String?
    var url: String
    var resourceType: String
    var transcript: String?

    enum CodingKeys: String, CodingKey {
        case content_id
        case name
        case details
        case url
        case resourceType
        case transcript
    }
}

struct ContentUpdate: Codable {
    var name: String?
    var details: String?
    var url: String?
    var resourceType: String?
    var transcript: String?
}
