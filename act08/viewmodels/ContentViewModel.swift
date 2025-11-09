//
//  ContentViewModel.swift
//  act08
//
//  Created by diegoh on 11/08/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ContentViewModel: ObservableObject {
    @Published var contents: [Content] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let repository = ContentRepository()

    func fetchContents() async {
        isLoading = true
        errorMessage = nil
        do {
            contents = try await repository.getAll()
        } catch let apiError as ApiError {
            errorMessage = apiError.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func createContent(name: String, details: String, url: String, resourceType: ResourceType, transcript: String?, course: Int, level: Int, lection: Int, resource: Int) async {
        let newContent = ContentCreate(name: name, details: details, url: url, resourceType: resourceType, transcript: transcript, course: course, level: level, lection: lection, resource: resource)
        do {
            let createdContent = try await repository.create(content: newContent)
            contents.append(createdContent)
        } catch let apiError as ApiError {
            errorMessage = apiError.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    func updateContent(content: Content) async {
        let contentUpdate = ContentUpdate(name: content.name, details: content.details, url: content.url, resourceType: content.resourceType, transcript: content.transcript, course: content.course, level: content.level, lection: content.lection, resource: content.resource)
        do {
            let updatedContent = try await repository.update(id: content.id, content: contentUpdate)
            if let index = contents.firstIndex(where: { $0.id == content.id }) {
                contents[index] = updatedContent
            }
        } catch let apiError as ApiError {
            errorMessage = apiError.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    func deleteContent(at offsets: IndexSet) {
        let idsToDelete = offsets.map { contents[$0].id }
        Task {
            for id in idsToDelete {
                do {
                    try await repository.delete(id: id)
                    contents.removeAll { $0.id == id }
                } catch let apiError as ApiError {
                    errorMessage = apiError.localizedDescription
                } catch {
                    errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                }
            }
        }
    }
}
