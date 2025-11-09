//
//  act08App.swift
//  act08
//
//  Created by Alumno on 24/10/25.
//

import SwiftUI
import SwiftData

@main
struct act08App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
