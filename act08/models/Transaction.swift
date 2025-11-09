//
//  Item.swift
//  act08
//
//  Created by Alumno on 24/10/25.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var createdAt: Date
    var updatedAt: Date?
    var deletedAt: Date? // For soft removal
    
    var date: Date
    var amount: Decimal
    var concept: String?
    
    init(date: Date, amount: Decimal, concept: String?) {
        self.createdAt = Date()
        self.date = date
        self.amount = amount
        self.concept = concept
    }
    
    func formattedAmount() -> String {
        let number = self.amount as NSDecimalNumber
        // Currency.FormatStyle works with Double/NSNumber; we format NSNumber via NumberFormatter below,
        // or use a Double conversion if precision is acceptable.
        let doubleValue = number.doubleValue
        return doubleValue.formatted(.currency(code: "MXN"))
    }
}
