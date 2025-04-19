//
//  HaloZone_BLEApp.swift
//  HaloZone_BLE
//
//  Created by 성현 on 4/12/25.
//

import SwiftUI
import SwiftData

@main
struct HaloZone_BLEApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isProfileInitialized") var isProfileInitialized = false

    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
                if isProfileInitialized {
                    HaloMainView()
                } else {
                    InitialProfileSetupView(isProfileInitialized: $isProfileInitialized)
                }
            }
        }
}
