//
//  ContentRepository.swift
//  act08
//
//  Created by diegoh on 11/08/25.
//

import Foundation

enum ApiError: Error {
    case invalidURL
    case requestError(String)
    case decodingError(String)
    case encodingError(String)
    case unknownError
}

class ContentRepository {

    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    func getAll() async throws -> [Content] {
        guard let url = URL(string: "\(ApiConfig.baseUrl)/content") else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ApiError.requestError("Invalid response")
        }

        do {
            let contents = try jsonDecoder.decode([Content].self, from: data)
            return contents
        } catch {
            throw ApiError.decodingError(error.localizedDescription)
        }
    }

    func create(content: ContentCreate) async throws -> Content {
        guard let url = URL(string: "\(ApiConfig.baseUrl)/content") else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try jsonEncoder.encode(content)
            request.httpBody = jsonData
        } catch {
            throw ApiError.encodingError(error.localizedDescription)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw ApiError.requestError("Invalid response")
        }

        do {
            let createdContent = try jsonDecoder.decode(Content.self, from: data)
            return createdContent
        } catch {
            throw ApiError.decodingError(error.localizedDescription)
        }
    }

    func update(id: Int, content: ContentUpdate) async throws -> Content {
        guard let url = URL(string: "\(ApiConfig.baseUrl)/content/\(id)") else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(content)
            request.httpBody = jsonData
        } catch {
            throw ApiError.encodingError(error.localizedDescription)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ApiError.requestError("Invalid response")
        }

        do {
            let updatedContent = try JSONDecoder().decode(Content.self, from: data)
            return updatedContent
        } catch {
            throw ApiError.decodingError(error.localizedDescription)
        }
    }

    func delete(id: Int) async throws {
        guard let url = URL(string: "\(ApiConfig.baseUrl)/content/\(id)") else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ApiError.requestError("Invalid response")
        }
    }
}
