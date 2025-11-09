//
//  ContentRepository.swift
//  act08
//
//  Created by diegoh on 11/08/25.
//

import Foundation

enum ApiError: Error {
    case invalidURL
    case networkError(String)
    case badRequest(String)
    case unprocessableEntity(String)
    case requestError(String)
    case decodingError(String)
    case encodingError(String)
    case serverError(String)
    case unknownError

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The server URL is invalid. Please check your configuration."
        case .networkError(let message):
            return "Network error: \(message). Please check your internet connection."
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .unprocessableEntity(let message):
            return "Validation error: \(message)"
        case .requestError(let message):
            return "Request failed: \(message)"
        case .decodingError(let message):
            return "Failed to process server response: \(message)"
        case .encodingError(let message):
            return "Failed to prepare request: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
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

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw ApiError.networkError("No internet connection")
            case .cannotConnectToHost, .cannotFindHost:
                throw ApiError.networkError("Cannot connect to server. Make sure the server is running.")
            case .timedOut:
                throw ApiError.networkError("Request timed out")
            default:
                throw ApiError.networkError(error.localizedDescription)
            }
        } catch {
            throw ApiError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.requestError("Invalid response from server")
        }

        switch httpResponse.statusCode {
        case 201:
            do {
                let createdContent = try jsonDecoder.decode(Content.self, from: data)
                return createdContent
            } catch {
                throw ApiError.decodingError(error.localizedDescription)
            }
        case 400:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Invalid data provided"
            throw ApiError.badRequest(errorMessage)
        case 422:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Some fields are invalid or missing"
            throw ApiError.unprocessableEntity(errorMessage)
        case 500...599:
            throw ApiError.serverError("The server encountered an error. Please try again later.")
        default:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unexpected error occurred"
            throw ApiError.requestError("Status \(httpResponse.statusCode): \(errorMessage)")
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
            let jsonData = try jsonEncoder.encode(content)
            request.httpBody = jsonData
        } catch {
            throw ApiError.encodingError(error.localizedDescription)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw ApiError.networkError("No internet connection")
            case .cannotConnectToHost, .cannotFindHost:
                throw ApiError.networkError("Cannot connect to server. Make sure the server is running.")
            case .timedOut:
                throw ApiError.networkError("Request timed out")
            default:
                throw ApiError.networkError(error.localizedDescription)
            }
        } catch {
            throw ApiError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.requestError("Invalid response from server")
        }

        switch httpResponse.statusCode {
        case 200:
            do {
                let updatedContent = try jsonDecoder.decode(Content.self, from: data)
                return updatedContent
            } catch {
                throw ApiError.decodingError(error.localizedDescription)
            }
        case 400:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Invalid data provided"
            throw ApiError.badRequest(errorMessage)
        case 422:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Some fields are invalid or missing"
            throw ApiError.unprocessableEntity(errorMessage)
        case 500...599:
            throw ApiError.serverError("The server encountered an error. Please try again later.")
        default:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unexpected error occurred"
            throw ApiError.requestError("Status \(httpResponse.statusCode): \(errorMessage)")
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
