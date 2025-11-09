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
    @State private var resourceType = ""
    @State private var transcript = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Content")) {
                    TextField("Name", text: $name)
                    TextField("Details", text: $details)
                    TextField("URL", text: $url)
                    TextField("Resource Type", text: $resourceType)
                    TextField("Transcript", text: $transcript)
                }

                Button("Add") {
                    Task {
                        await viewModel.createContent(name: name, details: details, url: url, resourceType: resourceType, transcript: transcript)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Add Content")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
