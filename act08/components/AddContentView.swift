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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Content")) {
                    TextField("Name", text: $name)
                    TextField("Details", text: $details)
                    TextField("URL", text: $url)
                    Picker("Resource Type", selection: $resourceType) {
                        ForEach(ResourceType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                    TextField("Transcript", text: $transcript)
                    TextField("Course", text: $course)
                        .keyboardType(.numberPad)
                    TextField("Level", text: $level)
                        .keyboardType(.numberPad)
                    TextField("Lection", text: $lection)
                        .keyboardType(.numberPad)
                    TextField("Resource", text: $resource)
                        .keyboardType(.numberPad)
                }

                Button("Add") {
                    Task {
                        isLoading = true
                        await viewModel.createContent(
                            name: name,
                            details: details,
                            url: url,
                            resourceType: resourceType,
                            transcript: transcript,
                            course: Int(course) ?? 0,
                            level: Int(level) ?? 0,
                            lection: Int(lection) ?? 0,
                            resource: Int(resource) ?? 0
                        )
                        isLoading = false
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(isLoading)

                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Add Content")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
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
