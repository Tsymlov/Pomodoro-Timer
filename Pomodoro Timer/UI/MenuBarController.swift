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
    // MARK: - Constants
    
    private enum Constants {
        static let updateInterval: TimeInterval = 1.0
        static let iconSize = NSSize(width: 18, height: 18)
        static let circleInset: CGFloat = 1.5
        static let borderInset: CGFloat = 0.5
        static let borderWidth: CGFloat = 1.0
        static let backgroundAlpha: CGFloat = 0.2
        static let windowCreationDelay: TimeInterval = 0.5
    }
    
    // MARK: - Properties
    
    private var statusItem: NSStatusItem?
    private let store: Store
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    
    // MARK: - Initialization
    
    init(store: Store) {
        self.store = store
        setupMenuBar()
        setupObservers()
    }
    
    deinit {
        updateTimer?.invalidate()
        updateTimer = nil
        statusItem = nil
    }
    
    // MARK: - Setup
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureStatusButton()
        updateMenuBarDisplay()
    }
    
    private func configureStatusButton() {
        guard let button = statusItem?.button else { return }
        button.action = #selector(menuBarButtonClicked)
        button.target = self
    }
    
    private func setupObservers() {
        observeStateChanges()
        setupUpdateTimer()
    }
    
    private func observeStateChanges() {
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarDisplay()
            }
            .store(in: &cancellables)
    }
    
    private func setupUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.updateInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleTimerUpdate()
            }
        }
    }
    
    private func handleTimerUpdate() {
        guard store.timerState == .running else { return }
        updateMenuBarDisplay()
    }
    
    // MARK: - UI Updates
    
    private func updateMenuBarDisplay() {
        guard let button = statusItem?.button else { return }
        button.image = createProgressImage(progress: store.progress)
        button.attributedTitle = NSAttributedString(string: "")
    }
    
    // MARK: - Progress Image Creation
    
    private func createProgressImage(progress: Double) -> NSImage {
        let image = NSImage(size: Constants.iconSize, flipped: false) { [weak self] rect in
            self?.drawProgressCircle(in: rect, progress: progress) ?? false
        }
        image.isTemplate = false
        return image
    }
    
    private func drawProgressCircle(in rect: NSRect, progress: Double) -> Bool {
        let center = NSPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - Constants.circleInset
        
        drawBackground(in: rect)
        drawProgress(center: center, radius: radius, progress: progress)
        drawBorder(in: rect)
        
        return true
    }
    
    private func drawBackground(in rect: NSRect) {
        NSColor.tertiaryLabelColor
            .withAlphaComponent(Constants.backgroundAlpha)
            .setFill()
        NSBezierPath(ovalIn: rect.insetBy(
            dx: Constants.circleInset,
            dy: Constants.circleInset
        )).fill()
    }
    
    private func drawProgress(center: NSPoint, radius: CGFloat, progress: Double) {
        guard progress > 0 else { return }
        
        let path = createProgressPath(
            center: center,
            radius: radius,
            progress: progress
        )
        
        progressColor.setFill()
        path.fill()
    }
    
    private func createProgressPath(center: NSPoint, radius: CGFloat, progress: Double) -> NSBezierPath {
        let startAngle: CGFloat = 90
        let endAngle = startAngle - (360 * progress)
        
        let path = NSBezierPath()
        path.move(to: center)
        path.appendArc(
            withCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        path.close()
        return path
    }
    
    private var progressColor: NSColor {
        if store.timerState == .completed {
            return .systemGreen
        }
        
        switch store.currentSession {
        case .pomodoro:
            return .labelColor
        case .shortBreak:
            return .systemBlue
        case .longBreak:
            return .systemPurple
        }
    }
    
    private func drawBorder(in rect: NSRect) {
        NSColor.labelColor.setStroke()
        let borderPath = NSBezierPath(ovalIn: rect.insetBy(
            dx: Constants.borderInset,
            dy: Constants.borderInset
        ))
        borderPath.lineWidth = Constants.borderWidth
        borderPath.stroke()
    }
    
    // MARK: - Menu Creation
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        buildMenuItems(for: menu)
        configureMenuTargets(for: menu)
        return menu
    }
    
    private func buildMenuItems(for menu: NSMenu) {
        addStatusItem(to: menu)
        menu.addItem(.separator())
        
        addTimerControls(to: menu)
        menu.addItem(.separator())
        
        addWindowControl(to: menu)
        menu.addItem(.separator())
        
        addQuitItem(to: menu)
    }
    
    private func configureMenuTargets(for menu: NSMenu) {
        menu.items
            .filter { $0.action != nil }
            .forEach { $0.target = self }
    }
    
    // MARK: - Menu Items
    
    private func addStatusItem(to menu: NSMenu) {
        let statusItem = NSMenuItem(
            title: statusText,
            action: nil,
            keyEquivalent: ""
        )
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
            menu.addItem(createMenuItem(
                title: title,
                action: #selector(startTimer),
                keyEquivalent: "s"
            ))
        }
        
        if store.canPause {
            menu.addItem(createMenuItem(
                title: "Pause Timer",
                action: #selector(pauseTimer),
                keyEquivalent: "p"
            ))
        }
        
        if store.canReset {
            menu.addItem(createMenuItem(
                title: "Reset Timer",
                action: #selector(resetTimer),
                keyEquivalent: "r"
            ))
        }
    }
    
    private func addBreakOptions(to menu: NSMenu) {
        guard store.timerState == .idle else { return }
        
        menu.addItem(.separator())
        menu.addItem(createMenuItem(
            title: "Start Short Break",
            action: #selector(startShortBreak)
        ))
        menu.addItem(createMenuItem(
            title: "Start Long Break",
            action: #selector(startLongBreak)
        ))
    }
    
    private func addWindowControl(to menu: NSMenu) {
        menu.addItem(createMenuItem(
            title: "Show Window",
            action: #selector(showMainWindow)
        ))
    }
    
    private func addQuitItem(to menu: NSMenu) {
        menu.addItem(createMenuItem(
            title: "Quit Pomodoro Timer",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))
    }
    
    private func createMenuItem(
        title: String,
        action: Selector?,
        keyEquivalent: String = ""
    ) -> NSMenuItem {
        NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
    }
    
    // MARK: - Computed Properties
    
    private var statusText: String {
        switch store.timerState {
        case .running:
            return store.currentSession.displayName
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
        statusItem?.menu = nil
    }
    
    @objc private func startTimer() {
        sendAction(store.timerState == .paused ? .resume : .start)
    }
    
    @objc private func pauseTimer() {
        sendAction(.pause)
    }
    
    @objc private func resetTimer() {
        sendAction(.reset)
    }
    
    @objc private func startShortBreak() {
        sendAction(.startShortBreak)
    }
    
    @objc private func startLongBreak() {
        sendAction(.startLongBreak)
    }
    
    private func sendAction(_ action: Action) {
        Task { @MainActor in
            store.send(action)
        }
    }
    
    @objc private func showMainWindow() {
        Task { @MainActor in
            activateApp()
            showOrCreateMainWindow()
        }
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Window Management
    
    private func activateApp() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func showOrCreateMainWindow() {
        if let window = findMainWindow() {
            showWindow(window)
        } else {
            reopenApplication()
        }
    }
    
    private func findMainWindow() -> NSWindow? {
        NSApp.windows.first { window in
            window.canBecomeMain && !isSystemWindow(window)
        }
    }
    
    private func isSystemWindow(_ window: NSWindow) -> Bool {
        let className = NSStringFromClass(type(of: window))
        return ["StatusBar", "Panel", "TitlebarAccessoryView"]
            .contains { className.contains($0) }
    }
    
    private func showWindow(_ window: NSWindow) {
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.deminiaturize(nil)
        window.setIsVisible(true)
    }
    
    private func reopenApplication() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier,
              let url = NSWorkspace.shared.urlForApplication(
                withBundleIdentifier: bundleIdentifier
              ) else { return }
        
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        NSWorkspace.shared.openApplication(
            at: url,
            configuration: configuration
        ) { [weak self] _, _ in
            self?.delayedWindowCheck()
        }
    }
    
    private func delayedWindowCheck() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.windowCreationDelay
        ) { [weak self] in
            if let window = self?.findMainWindow() {
                self?.showWindow(window)
            }
        }
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