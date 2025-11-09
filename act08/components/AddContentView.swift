//
//  AddContentView.swift
//  act08
//
//  Created by diegoh on 11/08/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

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

    private var showAlert: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private var isFormValid: Bool {
        let hasName = !name.trimmingCharacters(in: .whitespaces).isEmpty
        let hasDetails = !details.trimmingCharacters(in: .whitespaces).isEmpty
        let hasUrl = !url.trimmingCharacters(in: .whitespaces).isEmpty
        let hasCourse = !course.isEmpty
        let hasLevel = !level.isEmpty
        let hasLection = !lection.isEmpty
        let hasResource = !resource.isEmpty

        return hasName && hasDetails && hasUrl && hasCourse && hasLevel && hasLection && hasResource
    }

    private var overlayBackgroundColor: Color {
#if os(iOS)
        return Color(.systemBackground)
#else
        return Color(nsColor: .windowBackgroundColor)
#endif
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Content")) {
                    TextField("Name *", text: $name)
                    TextField("Details *", text: $details)
                    urlField
                    Picker("Resource Type *", selection: $resourceType) {
                        ForEach(ResourceType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                    TextField("Transcript (optional)", text: $transcript)
                    numericTextField(title: "Course *", text: $course)
                    numericTextField(title: "Level *", text: $level)
                    numericTextField(title: "Lection *", text: $lection)
                    numericTextField(title: "Resource *", text: $resource)
                }

                Section {
                    Text("* Required fields")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button("Add") {
                    Task {
                        isLoading = true
                        let courseValue = Int(course) ?? 0
                        let levelValue = Int(level) ?? 0
                        let lectionValue = Int(lection) ?? 0
                        let resourceValue = Int(resource) ?? 0
                        let transcriptValue = transcript.isEmpty ? nil : transcript

                        let success = await viewModel.createContent(
                            name: name,
                            details: details,
                            url: url,
                            resourceType: resourceType,
                            transcript: transcriptValue,
                            course: courseValue,
                            level: levelValue,
                            lection: lectionValue,
                            resource: resourceValue
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
            #if os(iOS)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            #endif
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
                            .background(overlayBackgroundColor)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                        }
                    }
                }
            )
            .alert("Error", isPresented: showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    @ViewBuilder
    private var urlField: some View {
#if os(iOS)
        TextField("URL *", text: $url)
            .autocapitalization(.none)
            .keyboardType(.URL)
#else
        TextField("URL *", text: $url)
#endif
    }

    @ViewBuilder
    private func numericTextField(title: String, text: Binding<String>) -> some View {
#if os(iOS)
        TextField(title, text: text)
            .keyboardType(.numberPad)
#else
        TextField(title, text: text)
#endif
    }
}
