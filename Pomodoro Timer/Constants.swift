//
//  Constants.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

enum Constants {
    static let pomodoroDuration: TimeInterval = 25 * 60 // 25 minutes
    static let shortBreakDuration: TimeInterval = 5 * 60 // 5 minutes
    static let longBreakDuration: TimeInterval = 15 * 60 // 15 minutes
    static let timeInterval: TimeInterval = 1 // 1 second
    static let pomodorosUntilLongBreak = 4
}
