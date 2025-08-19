//
//  Store.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var state = AppState()

    private let timer: TimerProtocol
    private var cancellables = Set<AnyCancellable>()
    private let notifier = Notifier.shared
    private let persistence = Persistence.shared
    private lazy var backgroundHandler = BackgroundHandler(store: self)

    // MARK: - Initialization
    init(timer: TimerProtocol = SystemTimer()) {
        self.timer = timer
        setupTimer()
        loadState()
        notifier.requestPermission()
        _ = backgroundHandler
    }

    // MARK: - Action Dispatch
    func send(_ action: Action) {
        let previousState = state
        reducer(state: &state, action: action)
        handleSideEffects(previousState: previousState, action: action)
        
        // Save state with optimization for frequent updates
        let shouldSaveImmediately = action.shouldSaveImmediately
        persistence.saveAppState(state, immediately: shouldSaveImmediately)
    }

    // MARK: - Timer Setup
    private func setupTimer() {
        timer.publisher
            .sink { [weak self] _ in
                self?.send(.updateBackgroundTime)
            }
            .store(in: &cancellables)
    }

    // MARK: - Side Effects
    private func handleSideEffects(previousState: AppState, action: Action) {
        switch action {
        case .start, .resume:
            if state.timerState == .running {
                timer.start()
                scheduleNotificationForCurrentSession()
            }

        case .pause, .stop, .reset:
            timer.stop()
            notifier.cancelAllNotifications()

        case .complete, .updateBackgroundTime:
            // Check if session just completed
            if previousState.timerState == .running && state.timerState == .completed {
                handleSessionCompletion()
            }

        case .enterForeground:
            // Update notifications when returning from background if needed
            if state.timerState == .running {
                notifier.cancelAllNotifications()
                scheduleNotificationForCurrentSession()
            }

        case .updateSettings:
            persistence.saveSettings(state.settings)

        default:
            break
        }
    }

    // MARK: - Session Management
    private func handleSessionCompletion() {
        // Don't stop timer - let it continue for overtime display
        notifier.cancelAllNotifications()
        scheduleCompletionNotification()
        // Don't auto-transition - let user see overtime
    }
    
    
    // MARK: - State Management
    private func loadState() {
        // Try to load saved state, or use default with loaded settings
        if let savedState = persistence.loadAppState() {
            state = savedState
        } else {
            // Load just settings if no full state exists
            state.settings = persistence.loadSettings()
            state.timeRemaining = state.getCurrentSessionDuration()
        }
    }
    
    // MARK: - Notifications
    private func scheduleNotificationForCurrentSession() {
        notifier.scheduleNotification(
            for: state.currentSession,
            in: state.timeRemaining
        )
    }
    
    private func scheduleCompletionNotification() {
        notifier.scheduleNotification(
            for: state.currentSession,
            in: 0.1
        )
    }


    // MARK: - Convenience Getters
    var timerState: TimerState { state.timerState }
    var currentSession: SessionType { state.currentSession }
    var timeRemaining: TimeInterval { state.timeRemaining }
    var formattedTime: String { state.formattedTime }
    var progress: Double { state.progress }
    var statistics: TimerStatistics { state.statistics }
    var currentCycle: Int { state.currentCycle }
    var canStart: Bool { state.canStart }
    var canPause: Bool { state.canPause }
    var canReset: Bool { state.canReset }
    var settings: Settings { state.settings }
    var allGoals: [SessionGoal] { state.allGoals }
    
    // MARK: - Analytics Access
    var todayStats: DailyStats { state.statistics.todayStats }
    var last7DaysStats: [DailyStats] { state.statistics.last7DaysStats }
    var last30DaysStats: [DailyStats] { state.statistics.last30DaysStats }
    var weeklyAverage: Double { state.statistics.weeklyAverage }
    var mostProductiveHour: Int? { state.statistics.mostProductiveHour }
    var longestStreak: Int { state.statistics.longestStreak }
    var sessionHistory: [SessionRecord] { state.statistics.sessionHistory }
    var currentGoal: SessionGoal? { state.currentGoal }
    var isGoalInputPresented: Bool { state.isGoalInputPresented }
    
    func sessionsByGoalText() -> [String: [SessionRecord]] {
        state.statistics.sessionsByGoalText(goals: state.allGoals)
    }
    
    func statsForGoalText(_ goalText: String) -> (sessions: [SessionRecord], totalTime: TimeInterval, completedSessions: Int) {
        state.statistics.statsForGoalText(goalText, goals: state.allGoals)
    }
    
    func uniqueGoalTexts() -> [String] {
        state.statistics.uniqueGoalTexts(goals: state.allGoals)
    }
}

// MARK: - Pomodoro Cycles Display

extension Store {
    
    /// Returns a string displaying today's pomodoros organized by cycles
    var todayPomodorosCyclesDisplay: String {
        let completedPomodoros = state.statistics.todayStats.completedPomodoros
        return pomodorosCyclesString(for: completedPomodoros)
    }

    /// Formats a cycles string for the given number of completed pomodoros
    private func pomodorosCyclesString(for completedPomodoros: Int) -> String {
        let fullCycles = completedPomodoros / Constants.pomodorosUntilLongBreak
        let remainingPomodoros = completedPomodoros % Constants.pomodorosUntilLongBreak

        var cycleStrings: [String] = []

        // Add complete cycles
        for _ in 0..<fullCycles {
            cycleStrings.append("\(Constants.pomodorosUntilLongBreak)×")
        }

        // Add current incomplete cycle if there are pomodoros
        if remainingPomodoros > 0 {
            cycleStrings.append("\(remainingPomodoros)×")
        }

        // If no pomodoros at all, show starting message
        if cycleStrings.isEmpty {
            return "0×"
        }

        return cycleStrings.joined(separator: " ")
    }
}

