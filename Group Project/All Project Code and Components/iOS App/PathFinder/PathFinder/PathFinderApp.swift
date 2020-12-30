//
//  PathFinderApp.swift
//  PathFinder
//
//  Created by Jaryd Meek on 10/1/20.
//

import SwiftUI

@main
struct PathFinderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
