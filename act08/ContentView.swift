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
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.errorMessage = nil
                    }
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
