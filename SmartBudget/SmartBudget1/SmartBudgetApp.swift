//
//  SmartBudgetApp.swift
//  SmartBudget
//
//  Created by 陳信宇 on 2025/5/18.
//

import SwiftUI

@main
struct SmartBudgetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
