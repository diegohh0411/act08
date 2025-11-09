//
//  ContentView.swift
//  act08
//
//  Created by Alumno on 24/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    private var repo: TransactionRepository {
        TransactionRepository(context: context)
    }
    
    @State
    private var showModelError = false
    
    @Query(
        filter: #Predicate<Transaction> { tx in tx.deletedAt == nil },
        sort: \Transaction.date,
        order: .reverse
    ) private var txs: [Transaction]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(txs) { tx in
                    NavigationLink {
                        TransactionDetailView(transaction: tx)
                    } label: {
                        HStack {
                            Text(tx.date.formatted(date: .abbreviated, time: .omitted))
                            Text(tx.concept ?? "Sin concepto")
                            Text(tx.formattedAmount())
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .alert("Oh oh", isPresented: $showModelError) {
            Button("OK", role: .cancel) { }
            Button("Retry") { }
        } message: {
            Text("Tuvimos un error al guardar tu transacción")
        }
    }

    private func addItem() {
        withAnimation {
            let _ = repo.create()
            do {
                try repo.save()
            } catch {
                showModelError = true
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                repo.delete(txs[index])
            }
            try? repo.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
