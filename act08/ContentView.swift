//
//  ContentView.swift
//  act08
//
//  Created by Alumno on 24/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showingAddContent = false

    private var showAlert: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.contents) { content in
                    NavigationLink(destination: ContentDetailView(content: content, viewModel: viewModel)) {
                        VStack(alignment: .leading) {
                            Text(content.name)
                                .font(.headline)
                            Text(content.details)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteContent)
            }
            .navigationTitle("Content")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddContent = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                #endif
            }
            .sheet(isPresented: $showingAddContent) {
                AddContentView(viewModel: viewModel)
            }
            .onAppear {
                Task {
                    await viewModel.fetchContents()
                }
            }
            .alert("Error", isPresented: showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
