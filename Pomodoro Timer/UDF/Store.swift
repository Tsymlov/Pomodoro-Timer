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
        persistence.saveAppState(state, immediately: action.shouldSaveImmediately)
    }
    
    // MARK: - Public Methods
    func saveStateAndCancelNotifications() {
        persistence.saveAppState(state, immediately: true)
        notifier.cancelAllNotifications()
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
            
        case .skipToBreak, .skipToPomodoro:
            timer.stop()
            notifier.cancelAllNotifications()
            
        case .startShortBreak, .startLongBreak:
            timer.stop()
            notifier.cancelAllNotifications()
            if state.timerState == .running {
                timer.start()
                scheduleNotificationForCurrentSession()
            }

        case .complete, .updateBackgroundTime:
            if previousState.timerState == .running && state.timerState == .completed {
                handleSessionCompletion()
            }

        case .enterForeground:
            checkAndResetDailyCycle()
            
            if state.timerState == .running {
                scheduleNotificationForCurrentSession()
            }

        case .updateSettings, .saveEditingSettings:
            persistence.saveSettings(state.settings)

        default:
            break
        }
    }

    // MARK: - Session Management
    private func handleSessionCompletion() {
    }

    // MARK: - State Management
    private func loadState() {
        if let savedState = persistence.loadAppState() {
            state = savedState
            state.currentCycle = calculateCurrentCycle(for: state.statistics)
        } else {
            state.settings = persistence.loadSettings()
            state.timeRemaining = state.getCurrentSessionDuration()
            state.currentCycle = 1
        }
    }
    
    private func calculateCurrentCycle(for statistics: TimerStatistics) -> Int {
        let completedCyclesCount = statistics.todayStats.completedLongBreaks
        return completedCyclesCount + 1
    }
    
    private func checkAndResetDailyCycle() {
        state.currentCycle = calculateCurrentCycle(for: state.statistics)
    }

    // MARK: - Notifications
    private func scheduleNotificationForCurrentSession() {
        notifier.scheduleNotification(
            for: state.currentSession,
            in: state.timeRemaining
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
    var editingSettings: Settings? { state.editingSettings }

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
        let completedLongBreaks = state.statistics.todayStats.completedLongBreaks
        return pomodorosCyclesString(for: completedPomodoros, longBreaks: completedLongBreaks, currentCycle: state.currentCycle)
    }

    /// Formats a cycles string for the given number of completed pomodoros and cycles
    private func pomodorosCyclesString(for completedPomodoros: Int, longBreaks: Int, currentCycle: Int) -> String {
        guard completedPomodoros > 0 else { return "" }
        
        var cycleStrings: [String] = []
        var remainingPomodoros = completedPomodoros
        
        // Distribute pomodoros across completed cycles
        for _ in 0..<longBreaks {
            // Each completed cycle gets up to 4 pomodoros
            let pomodorosInThisCycle = min(Constants.pomodorosUntilLongBreak, remainingPomodoros)
            if pomodorosInThisCycle > 0 {
                cycleStrings.append("\(pomodorosInThisCycle)×")
                remainingPomodoros -= pomodorosInThisCycle
            }
        }
        
        // Add remaining pomodoros in current cycle
        if remainingPomodoros > 0 {
            cycleStrings.append("\(remainingPomodoros)×")
        }
        
        return cycleStrings.joined(separator: " ")
    }
}
