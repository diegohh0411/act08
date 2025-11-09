//
//  ContentDetailView.swift
//  act08
//
//  Created by diegoh on 11/08/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ContentDetailView: View {
    @State var content: Content
    @ObservedObject var viewModel: ContentViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false

    private var showAlert: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private var isFormValid: Bool {
        let hasName = !content.name.trimmingCharacters(in: .whitespaces).isEmpty
        let hasDetails = !content.details.trimmingCharacters(in: .whitespaces).isEmpty
        let hasUrl = !content.url.trimmingCharacters(in: .whitespaces).isEmpty

        return hasName && hasDetails && hasUrl
    }

    private var transcriptBinding: Binding<String> {
        Binding(
            get: { self.content.transcript ?? "" },
            set: { self.content.transcript = $0.isEmpty ? nil : $0 }
        )
    }

    private var overlayBackgroundColor: Color {
#if os(iOS)
        return Color(.systemBackground)
#else
        return Color(nsColor: .windowBackgroundColor)
#endif
    }

    var body: some View {
        Form {
            contentDetailsSection
            requiredFieldsSection
            saveButton
        }
        .navigationTitle("Edit Content")
        .disabled(isLoading)
        .overlay(loadingOverlay)
        .alert("Error", isPresented: showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var contentDetailsSection: some View {
        Section(header: Text("Content Details")) {
            TextField("Name *", text: $content.name)
            TextField("Details *", text: $content.details)
            urlField
            resourceTypePicker
            TextField("Transcript (optional)", text: transcriptBinding)
            courseFields
        }
    }

    @ViewBuilder
    private var urlField: some View {
        #if os(iOS)
        TextField("URL *", text: $content.url)
            .autocapitalization(.none)
            .keyboardType(.URL)
        #else
        TextField("URL *", text: $content.url)
        #endif
    }

    private var resourceTypePicker: some View {
        Picker("Resource Type *", selection: $content.resourceType) {
            ForEach(ResourceType.allCases, id: \.self) { type in
                Text(type.rawValue.capitalized)
            }
        }
    }

    private var courseFields: some View {
        Group {
            numericField(title: "Course *", value: $content.course)
            numericField(title: "Level *", value: $content.level)
            numericField(title: "Lection *", value: $content.lection)
            numericField(title: "Resource *", value: $content.resource)
        }
    }

    @ViewBuilder
    private func numericField(title: String, value: Binding<Int>) -> some View {
        #if os(iOS)
        TextField(title, value: value, format: .number)
            .keyboardType(.numberPad)
        #else
        TextField(title, value: value, format: .number)
        #endif
    }

    private var requiredFieldsSection: some View {
        Section {
            Text("* Required fields")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var saveButton: some View {
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

    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    Text("Updating content...")
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
}
