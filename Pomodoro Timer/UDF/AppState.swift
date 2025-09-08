//
//  AppState.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

struct AppState: Equatable, Codable {
    var timerState: TimerState = .idle
    var currentSession: SessionType = .pomodoro
    var timeRemaining: TimeInterval = Constants.pomodoroDuration
    var statistics: TimerStatistics = TimerStatistics()
    var currentCycle: Int = 1
    var settings: Settings = Settings()
    var currentSessionStartTime: Date?
    var currentGoal: SessionGoal?
    var isGoalInputPresented: Bool = false
    var allGoals: [SessionGoal] = []
    var sessionEndTime: Date?
    var backgroundTime: Date?
    var pausedTimeRemaining: TimeInterval?

    // MARK: - Computed Properties
    var progress: Double {
        // Show full circle when completed
        if timerState == .completed {
            return 1.0
        }

        let totalTime = getCurrentSessionDuration()
        return totalTime > 0 ? (totalTime - timeRemaining) / totalTime : 0
    }

    var formattedTime: String {
        if timerState == .completed, let startTime = currentSessionStartTime {
            let elapsedTime = Date().timeIntervalSince(startTime)
            let minutes = Int(elapsedTime) / 60
            let seconds = Int(elapsedTime) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }

        let minutes = Int(abs(timeRemaining)) / 60
        let seconds = Int(abs(timeRemaining)) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var canStart: Bool {
        timerState == .idle || timerState == .paused
    }

    var canPause: Bool {
        timerState == .running
    }

    var canReset: Bool {
        timerState != .idle
    }

    func getCurrentSessionDuration() -> TimeInterval {
        switch currentSession {
        case .pomodoro:
            return settings.pomodoroDuration
        case .shortBreak:
            return settings.shortBreakDuration
        case .longBreak:
            return settings.longBreakDuration
        }
    }
}
