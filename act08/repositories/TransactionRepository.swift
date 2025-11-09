//
//  TransactionRepository.swift
//  act08
//
//  Created by Alumno on 24/10/25.
//

import Foundation
import SwiftData
import os

final class TransactionRepository {
    private let context: ModelContext
    private let logger = Logger(subsystem: "TransactionRepository", category: "Repository")
    
    init(context: ModelContext) {
        self.context = context
    }
    
    @discardableResult
    func create(date: Date = Date(), amount: Decimal = 0, concept: String? = nil) -> Transaction {
        logger.debug("Creating transaction with concept: '\(concept ?? "nil")'")
        
        let tx = Transaction(date: date, amount: amount, concept: concept)
        context.insert(tx)
        
        return tx
    }
    
    func update(_ tx: Transaction, date: Date? = nil, amount: Decimal? = nil, concept: String? = nil) {
        if let date = date { tx.date = date }
        if let amount = amount { tx.amount = amount }
        if let concept = concept { tx.concept = concept }
        
        tx.updatedAt = Date()
    }
    
    func delete(_ tx: Transaction) {
        tx.deletedAt = Date()
        tx.updatedAt = Date()
    }
    
    func save() throws {
        try context.save()
    }
}
