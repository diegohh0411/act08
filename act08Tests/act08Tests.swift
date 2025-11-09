//
//  act08Tests.swift
//  act08Tests
//
//  Created by Alumno on 24/10/25.
//

import Testing
import SwiftUI
@testable import act08

struct act08Tests {
    @Test func correctConstructionOfATransaction() async throws {
        let tx1 = Transaction(date: Date(), amount: 2, concept: "Me regresaron dinero")
        #expect(tx1.amount > 0)
        #expect(tx1.deletedAt == nil)
    }

    @Test func correctRepresentationAsString() async throws {
        let tx2 = Transaction(date: Date(), amount: 1000000, concept: "La compra de una casa")
        #expect(tx2.formattedAmount() == "$1,000,000.00")
    }
}
