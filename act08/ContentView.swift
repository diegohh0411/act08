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
                            Text(content.details ?? "No details")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteContent)
            }
            .navigationTitle("Content")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddContent = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddContent) {
                AddContentView(viewModel: viewModel)
            }
            .onAppear {
                Task {
                    await viewModel.fetchContents()
                }
            }
            .alert(item: $viewModel.errorMessage) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
