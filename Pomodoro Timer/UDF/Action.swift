//
//  Action.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

enum Action: Equatable {
    case start
    case pause
    case resume
    case stop
    case reset
    case tick
    case complete
    case skipToBreak
    case skipToPomodoro
    case moveToNextSession
    case startShortBreak
    case startLongBreak
    case updateSettings(Settings)
    case setDailyGoal(Int)
    case resetDailyStatistics
    case showGoalInput
    case hideGoalInput
    case setGoal(String)
    case enterBackground
    case enterForeground
    case updateBackgroundTime
}

extension Action {
    var shouldSaveImmediately: Bool {
        switch self {
        case .tick, .updateBackgroundTime:
            // These happen frequently, use delayed save
            return false
        case .showGoalInput, .hideGoalInput:
            // UI state changes, no need to save immediately
            return false
        default:
            // Important state changes, save immediately
            return true
        }
    }
}
