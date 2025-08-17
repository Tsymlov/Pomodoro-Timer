//
//  Pomodoro_TimerApp.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 11.05.2025.
//

import SwiftUI
import SwiftData
#if os(macOS)
import Cocoa
#endif

@main
struct Pomodoro_TimerApp: App {
    init() {
        #if os(macOS)
        checkSingleInstance()
        #endif
    }
    
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
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    #if os(macOS)
    private func checkSingleInstance() {
        let runningApps = NSWorkspace.shared.runningApplications
        let appBundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        
        let sameApps = runningApps.filter { app in
            app.bundleIdentifier == appBundleIdentifier
        }
        
        if sameApps.count > 1 {
            if let existingApp = sameApps.first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) {
                existingApp.activate(options: [.activateAllWindows])
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.terminate(nil)
            }
        }
    }
    #endif
}
