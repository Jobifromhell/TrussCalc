//
//  TrussCalcApp.swift
//  TrussCalc
//
//  Created by Olivier Jobin on 06/06/2024.
//

import SwiftUI

@main
struct TrussCalcApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
