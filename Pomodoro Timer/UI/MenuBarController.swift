//
//  MenuBarController.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 17.08.2025.
//

#if os(macOS)
import AppKit
import SwiftUI
import Combine

@MainActor
final class MenuBarController: ObservableObject {
    // MARK: - Properties
    
    private var statusItem: NSStatusItem?
    private let store: Store
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    
    // MARK: - Initialization
    
    init(store: Store) {
        self.store = store
        setupMenuBar()
        observeStoreChanges()
    }
    
    // MARK: - Setup
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else { return }
        
        button.action = #selector(menuBarButtonClicked)
        button.target = self
        
        updateMenuBarDisplay()
    }
    
    private func observeStoreChanges() {
        // Observe state changes for menu updates
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarDisplay()
            }
            .store(in: &cancellables)
        
        // Start timer for regular updates when running
        startUpdateTimer()
    }
    
    private func startUpdateTimer() {
        updateTimer?.invalidate()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.store.timerState == .running {
                    self.updateMenuBarDisplay()
                }
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateMenuBarDisplay() {
        guard let button = statusItem?.button else { return }
        
        // Update icon
        updateIcon(for: button)
        
        // Update title (time display)
        updateTitle(for: button)
    }
    
    private func updateIcon(for button: NSStatusBarButton) {
        let iconName = iconNameForCurrentState()
        if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) {
            button.image = image
        }
    }
    
    private func updateTitle(for button: NSStatusBarButton) {
        // Show time for all states except completed
        if store.timerState != .completed {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            ]
            button.attributedTitle = NSAttributedString(string: " \(store.formattedTime)", attributes: attributes)
        } else {
            button.attributedTitle = NSAttributedString(string: "")
        }
    }
    
    private func iconNameForCurrentState() -> String {
        switch store.timerState {
        case .running:
            return store.currentSession == .pomodoro ? "timer" : "cup.and.saucer"
        case .paused:
            return "pause.circle"
        case .completed:
            return "checkmark.circle"
        case .idle:
            return "timer"
        }
    }
    
    // MARK: - Menu Creation
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        addStatusItem(to: menu)
        menu.addItem(.separator())
        
        addTimerControls(to: menu)
        menu.addItem(.separator())
        
        addWindowControl(to: menu)
        menu.addItem(.separator())
        
        addQuitItem(to: menu)
        
        // Set target for all action items
        menu.items.forEach { item in
            if item.action != nil {
                item.target = self
            }
        }
        
        return menu
    }
    
    private func addStatusItem(to menu: NSMenu) {
        let statusText = currentStatusText()
        let statusItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)
    }
    
    private func addTimerControls(to menu: NSMenu) {
        addMainTimerControls(to: menu)
        addBreakOptions(to: menu)
    }
    
    private func addMainTimerControls(to menu: NSMenu) {
        if store.canStart {
            let title = store.timerState == .paused ? "Resume Timer" : "Start Timer"
            menu.addItem(NSMenuItem(title: title, action: #selector(startTimer), keyEquivalent: "s"))
        }
        
        if store.canPause {
            menu.addItem(NSMenuItem(title: "Pause Timer", action: #selector(pauseTimer), keyEquivalent: "p"))
        }
        
        if store.canReset {
            menu.addItem(NSMenuItem(title: "Reset Timer", action: #selector(resetTimer), keyEquivalent: "r"))
        }
    }
    
    private func addBreakOptions(to menu: NSMenu) {
        guard store.timerState == .idle else { return }
        
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Start Short Break", action: #selector(startShortBreak), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Start Long Break", action: #selector(startLongBreak), keyEquivalent: ""))
    }
    
    private func addWindowControl(to menu: NSMenu) {
        menu.addItem(NSMenuItem(title: "Show Window", action: #selector(showMainWindow), keyEquivalent: ""))
    }
    
    private func addQuitItem(to menu: NSMenu) {
        menu.addItem(NSMenuItem(title: "Quit Pomodoro Timer", action: #selector(quitApp), keyEquivalent: "q"))
    }
    
    private func currentStatusText() -> String {
        switch store.timerState {
        case .running:
            return "\(store.currentSession.displayName)"
        case .paused:
            return "\(store.currentSession.displayName) - Paused"
        case .completed:
            return "\(store.currentSession.displayName) - Completed!"
        case .idle:
            return "Ready to start"
        }
    }
    
    // MARK: - Actions
    
    @objc private func menuBarButtonClicked(_ sender: NSStatusBarButton) {
        let menu = createMenu()
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        
        // Clean up menu after showing
        statusItem?.menu = nil
    }
    
    @objc private func startTimer() {
        Task { @MainActor in
            if store.timerState == .paused {
                store.send(.resume)
            } else {
                store.send(.start)
            }
        }
    }
    
    @objc private func pauseTimer() {
        Task { @MainActor in
            store.send(.pause)
        }
    }
    
    @objc private func resetTimer() {
        Task { @MainActor in
            store.send(.reset)
        }
    }
    
    @objc private func startShortBreak() {
        Task { @MainActor in
            store.send(.startShortBreak)
        }
    }
    
    @objc private func startLongBreak() {
        Task { @MainActor in
            store.send(.startLongBreak)
        }
    }
    
    @objc private func showMainWindow() {
        Task { @MainActor in
            // Switch to regular app mode to show windows
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            
            // Find existing main window
            let mainWindow = NSApp.windows.first { window in
                window.canBecomeMain && !isSystemWindow(window)
            }
            
            if let window = mainWindow {
                // Show existing window
                showWindow(window)
            } else {
                // Create new window by reopening the app
                reopenApplication()
            }
        }
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Window Management Helpers
    
    private func isSystemWindow(_ window: NSWindow) -> Bool {
        let className = NSStringFromClass(type(of: window))
        return className.contains("StatusBar") || 
               className.contains("Panel") ||
               className.contains("TitlebarAccessoryView")
    }
    
    private func showWindow(_ window: NSWindow) {
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.deminiaturize(nil)
        window.setIsVisible(true)
    }
    
    private func reopenApplication() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier,
              let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            return
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, _ in
            // Wait for window to be created
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                if let window = NSApp.windows.first(where: { $0.canBecomeMain && !(self?.isSystemWindow($0) ?? true) }) {
                    self?.showWindow(window)
                }
            }
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        updateTimer?.invalidate()
        statusItem = nil
    }
}

// MARK: - SessionType Extension

extension SessionType {
    var displayName: String {
        switch self {
        case .pomodoro:
            return "Focus"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
}

#endif