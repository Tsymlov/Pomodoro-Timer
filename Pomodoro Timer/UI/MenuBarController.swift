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
final class MenuBarController: NSObject, ObservableObject {
    // MARK: - Constants

    private var iconSize: NSSize {
        NSSize(width: Constants.menuBarIconSize, height: Constants.menuBarIconSize)
    }

    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private let store: Store
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    private var menuUpdateTimer: Timer?
    private weak var currentMenuTimerView: MenuTimerView?

    // MARK: - Initialization

    init(store: Store) {
        self.store = store
        super.init()
        setupMenuBar()
        setupObservers()
    }

    deinit {
        updateTimer?.invalidate()
        updateTimer = nil
        menuUpdateTimer?.invalidate()
        menuUpdateTimer = nil
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
            withTimeInterval: Constants.menuUpdateInterval,
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
        let image = NSImage(size: iconSize, flipped: false) { [weak self] rect in
            self?.drawProgressCircle(in: rect, progress: progress) ?? false
        }
        image.isTemplate = false
        return image
    }

    private func drawProgressCircle(in rect: NSRect, progress: Double) -> Bool {
        let center = NSPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - Constants.menuBarCircleInset

        drawBackground(in: rect)
        drawProgress(center: center, radius: radius, progress: progress)
        drawBorder(in: rect)

        return true
    }

    private func drawBackground(in rect: NSRect) {
        NSColor.tertiaryLabelColor
            .withAlphaComponent(Constants.menuBarBackgroundAlpha)
            .setFill()
        NSBezierPath(ovalIn: rect.insetBy(
            dx: Constants.menuBarCircleInset,
            dy: Constants.menuBarCircleInset
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
        let startAngle: CGFloat = Constants.menuBarProgressStartAngle
        let endAngle = startAngle - (Constants.menuBarProgressFullCircle * progress)

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
            dx: Constants.menuBarBorderInset,
            dy: Constants.menuBarBorderInset
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
        let timerView = MenuTimerView(store: store)
        timerView.updateDisplay()
        currentMenuTimerView = timerView

        let menuItem = NSMenuItem()
        menuItem.view = timerView
        menu.addItem(menuItem)
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
            title: "Show Pomodoro Timer",
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

    // MARK: - Actions

    @objc private func menuBarButtonClicked(_ sender: NSStatusBarButton) {
        let menu = createMenu()
        menu.delegate = self

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
            activateAppAndShowWindow()
        }
    }

    private func activateAppAndShowWindow() {
        NSApp.setActivationPolicy(.regular)

        if let window = findMainWindow() {
            showWindow(window)
        } else {
            reopenApplication()
        }

        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    // MARK: - Window Management

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
        window.setIsVisible(true)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.deminiaturize(nil)
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
            Task { @MainActor in
                self?.delayedWindowCheck()
            }
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

// MARK: - NSMenuDelegate

extension MenuBarController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        updateMenuTimerViewImmediately()
        startMenuUpdateTimer()
    }

    func menuDidClose(_ menu: NSMenu) {
        stopMenuUpdateTimer()
        clearMenuTimerView()
    }

    private func updateMenuTimerViewImmediately() {
        currentMenuTimerView?.updateDisplay()
    }

    private func startMenuUpdateTimer() {
        menuUpdateTimer?.invalidate()
        menuUpdateTimer = createMenuUpdateTimer()
        addTimerToRunLoop()
    }

    private func createMenuUpdateTimer() -> Timer {
        Timer.scheduledTimer(withTimeInterval: Constants.menuUpdateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.currentMenuTimerView?.updateDisplay()
            }
        }
    }

    private func addTimerToRunLoop() {
        if let timer = menuUpdateTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopMenuUpdateTimer() {
        menuUpdateTimer?.invalidate()
        menuUpdateTimer = nil
    }

    private func clearMenuTimerView() {
        currentMenuTimerView = nil
    }
}

#endif
