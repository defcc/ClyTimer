//
//  ClyTimer_iosApp.swift
//  ClyTimer-ios
//
//  Created by 程超 on 2024/7/28.
//

import SwiftUI

@main
struct ClyTimer_iosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
