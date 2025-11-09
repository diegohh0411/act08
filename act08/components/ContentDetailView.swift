//
//  ContentDetailView.swift
//  act08
//
//  Created by diegoh on 11/08/25.
//

import SwiftUI

struct ContentDetailView: View {
    @State var content: Content
    @ObservedObject var viewModel: ContentViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false

    private var isFormValid: Bool {
        !content.name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.details.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.url.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            Section(header: Text("Content Details")) {
                TextField("Name *", text: $content.name)
                TextField("Details *", text: $content.details)
                TextField("URL *", text: $content.url)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
                Picker("Resource Type *", selection: $content.resourceType) {
                    ForEach(ResourceType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized)
                    }
                }
                TextField("Transcript (optional)", text: Binding(
                    get: { self.content.transcript ?? "" },
                    set: { self.content.transcript = $0.isEmpty ? nil : $0 }
                ))
                TextField("Course *", value: $content.course, format: .number)
                    .keyboardType(.numberPad)
                TextField("Level *", value: $content.level, format: .number)
                    .keyboardType(.numberPad)
                TextField("Lection *", value: $content.lection, format: .number)
                    .keyboardType(.numberPad)
                TextField("Resource *", value: $content.resource, format: .number)
                    .keyboardType(.numberPad)
            }

            Section {
                Text("* Required fields")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button("Save") {
                Task {
                    isLoading = true
                    let success = await viewModel.updateContent(content: content)
                    isLoading = false
                    if success {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .disabled(isLoading || !isFormValid)
        }
        .navigationTitle("Edit Content")
        .disabled(isLoading)
        .overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Updating content...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(30)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }
                }
            }
        )
        .alert(item: Binding<String?>(
            get: { viewModel.errorMessage },
            set: { viewModel.errorMessage = $0 }
        )) { error in
            Alert(
                title: Text("Error"),
                message: Text(error),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
