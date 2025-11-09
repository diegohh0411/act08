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
                }

                Button("Add") {
                    Task {
                        isLoading = true
                        await viewModel.createContent(
                            name: name,
                            details: details,
                            url: url,
                            resourceType: resourceType,
                            transcript: transcript
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
