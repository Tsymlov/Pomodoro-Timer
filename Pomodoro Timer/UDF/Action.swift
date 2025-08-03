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
    case updateSettings(Settings)
    case setDailyGoal(Int)
    case resetDailyStatistics
    case showGoalInput
    case hideGoalInput
    case setGoal(String)
    case completeCurrentGoal
}
