//
//  Settings.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

struct Settings: Codable, Equatable {
    var pomodoroDuration: TimeInterval = Constants.pomodoroDuration
    var shortBreakDuration: TimeInterval = Constants.shortBreakDuration
    var longBreakDuration: TimeInterval = Constants.longBreakDuration
    var dailyGoal: Int = 8
    var autoStartBreaks: Bool = false
    var autoStartPomodoros: Bool = false
    var soundEnabled: Bool = true
    var vibrateEnabled: Bool = true

}
