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
    private let notificationManager = NotificationManager.shared
    
    // MARK: - Initialization
    init(timer: TimerProtocol = SystemTimer()) {
        self.timer = timer
        setupTimer()
        loadSettings()
        notificationManager.requestPermission()
    }
    
    // MARK: - Action Dispatch
    func send(_ action: Action) {
        let previousState = state
        reducer(state: &state, action: action)
        handleSideEffects(previousState: previousState, action: action)
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
            notificationManager.cancelAllNotifications()
            
        case .complete:
            if previousState.timerState == .running && state.timerState == .completed {
                timer.stop()
                notificationManager.cancelAllNotifications()
                scheduleCompletionNotification()
                
                // Auto move to next session after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.send(.moveToNextSession)
                }
            }
            
        case .tick:
            if previousState.timerState == .running && state.timerState == .completed {
                timer.stop()
                notificationManager.cancelAllNotifications()
                scheduleCompletionNotification()
                
                // Auto move to next session after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.send(.moveToNextSession)
                }
            }
            
        case .updateSettings:
            state.settings.save()
            
        default:
            break
        }
    }
    
    // MARK: - Timer Setup
    private func setupTimer() {
        timer.publisher
            .sink { [weak self] _ in
                self?.send(.tick)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Settings
    private func loadSettings() {
        let loadedSettings = Settings.load()
        send(.updateSettings(loadedSettings))
    }
    
    // MARK: - Notifications
    private func scheduleNotificationForCurrentSession() {
        notificationManager.scheduleNotification(
            for: state.currentSession,
            in: state.timeRemaining
        )
    }
    
    private func scheduleCompletionNotification() {
        notificationManager.scheduleNotification(
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
