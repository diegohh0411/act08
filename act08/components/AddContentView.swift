//
//  AddContentView.swift
//  act08
//
//  Created by diegoh on 11/08/25.
//

import SwiftUI

struct AddContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var details = ""
    @State private var url = ""
    @State private var resourceType: ResourceType = .video
    @State private var transcript = ""
    @State private var course = ""
    @State private var level = ""
    @State private var lection = ""
    @State private var resource = ""
    @State private var isLoading = false

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !details.trimmingCharacters(in: .whitespaces).isEmpty &&
        !url.trimmingCharacters(in: .whitespaces).isEmpty &&
        !course.isEmpty &&
        !level.isEmpty &&
        !lection.isEmpty &&
        !resource.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Content")) {
                    TextField("Name *", text: $name)
                    TextField("Details *", text: $details)
                    TextField("URL *", text: $url)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    Picker("Resource Type *", selection: $resourceType) {
                        ForEach(ResourceType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                    TextField("Transcript (optional)", text: $transcript)
                    TextField("Course *", text: $course)
                        .keyboardType(.numberPad)
                    TextField("Level *", text: $level)
                        .keyboardType(.numberPad)
                    TextField("Lection *", text: $lection)
                        .keyboardType(.numberPad)
                    TextField("Resource *", text: $resource)
                        .keyboardType(.numberPad)
                }

                Section {
                    Text("* Required fields")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button("Add") {
                    Task {
                        isLoading = true
                        let success = await viewModel.createContent(
                            name: name,
                            details: details,
                            url: url,
                            resourceType: resourceType,
                            transcript: transcript.isEmpty ? nil : transcript,
                            course: Int(course) ?? 0,
                            level: Int(level) ?? 0,
                            lection: Int(lection) ?? 0,
                            resource: Int(resource) ?? 0
                        )
                        isLoading = false
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(isLoading || !isFormValid)
            }
            .navigationTitle("Add Content")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
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
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                Text("Creating content...")
                                    .foregroundColor(.primary)
                                    .font(.headline)
                            }
                            .padding(30)
                            .background(Color(.systemBackground))
                            .cornerRadius(15)
                            .shadow(radius: 10)
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
}
