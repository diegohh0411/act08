//
//  TransactionView.swift
//  act08
//
//  Created by Alumno on 24/10/25.
//

import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.modelContext) private var context
    private var repo: TransactionRepository { TransactionRepository(context: context) }

    let transaction: Transaction

    @State private var amountText: String = ""

    var body: some View {
        Form {
            DatePicker("Date", selection: bindingDate)
            TextField("Concept", text: bindingConcept)
            
            TextField("Amount", text: $amountText)
                .onAppear {
                    amountText = transaction.amount.formatted() // preload
                }
                .onChange(of: amountText) { newValue in
                    // Keep model in sync when amountText parses
                    if let decimal = Decimal(string: newValue) {
                        transaction.amount = decimal
                    }
                }

            if let updated = transaction.updatedAt {
                Text("Last updated: \(updated.formatted())").font(.footnote).foregroundStyle(.secondary)
            }
            if let deleted = transaction.deletedAt {
                Text("Deleted: \(deleted.formatted())").font(.footnote).foregroundStyle(.red)
            }
        }
        .navigationTitle("Transacción")
    }

    // Bindings to optional and non-optional fields

    private var bindingDate: Binding<Date> {
        Binding(
            get: { transaction.date },
            set: { transaction.date = $0 }
        )
    }

    private var bindingConcept: Binding<String> {
        Binding(
            get: { transaction.concept ?? "" },
            set: { transaction.concept = $0.isEmpty ? nil : $0 }
        )
    }
}
