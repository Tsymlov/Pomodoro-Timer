//
//  Pomodoro_TimerApp.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 11.05.2025.
//

import SwiftUI
#if os(macOS)
import Cocoa
#endif

@main
struct Pomodoro_TimerApp: App {
    @StateObject private var store: Store
    #if os(macOS)
    @StateObject private var menuBarController: MenuBarController
    #endif
    
    init() {
        let storeInstance = Store()
        self._store = StateObject(wrappedValue: storeInstance)
        
        #if os(macOS)
        self._menuBarController = StateObject(wrappedValue: MenuBarController(store: storeInstance))
        checkSingleInstance()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(store)
                #if os(macOS)
                .onAppear {
                    setupAppBehavior()
                }
                #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }
    
    #if os(macOS)
    private func setupAppBehavior() {
        // Keep app running even when window is closed
        // This allows the menu bar to stay active
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
    }
    
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
