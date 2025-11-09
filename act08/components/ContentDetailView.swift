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

    var body: some View {
        Form {
            Section(header: Text("Content Details")) {
                TextField("Name", text: $content.name)
                TextField("Details", text: Binding(
                    get: { self.content.details ?? "" },
                    set: { self.content.details = $0 }
                ))
                TextField("URL", text: $content.url)
                Picker("Resource Type", selection: $content.resourceType) {
                    ForEach(ResourceType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized)
                    }
                }
                TextField("Transcript", text: Binding(
                    get: { self.content.transcript ?? "" },
                    set: { self.content.transcript = $0 }
                ))
                TextField("Course", value: $content.course, format: .number)
                    .keyboardType(.numberPad)
                TextField("Level", value: $content.level, format: .number)
                    .keyboardType(.numberPad)
                TextField("Lection", value: $content.lection, format: .number)
                    .keyboardType(.numberPad)
                TextField("Resource", value: $content.resource, format: .number)
                    .keyboardType(.numberPad)
            }

            Button("Save") {
                Task {
                    await viewModel.updateContent(content: content)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Edit Content")
    }
}
