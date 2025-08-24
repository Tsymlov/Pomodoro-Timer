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
        // Start the app in accessory mode (no Dock icon)
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(store)
                #if os(macOS)
                .frame(minWidth: 320, idealWidth: 320, maxWidth: 320,
                       minHeight: 460, idealHeight: 460, maxHeight: 460)
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
                    if let window = notification.object as? NSWindow,
                       window.isVisible {
                        // When the main window closes, switch back to accessory mode
                        DispatchQueue.main.async {
                            NSApp.setActivationPolicy(.accessory)
                        }
                    }
                }
                #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 320, height: 460)
        #endif
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
