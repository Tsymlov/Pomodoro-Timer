//
//  SessionType.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

enum SessionType: CaseIterable, Equatable, Codable {
    case pomodoro
    case shortBreak
    case longBreak

    var duration: TimeInterval {
        switch self {
        case .pomodoro:
            return Constants.pomodoroDuration // 25 minutes
        case .shortBreak:
            return Constants.shortBreakDuration // 5 minutes
        case .longBreak:
            return Constants.longBreakDuration // 15 minutes
        }
    }

    var title: String {
        switch self {
        case .pomodoro:
            return "Focus"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }

    var emoji: String {
        switch self {
        case .pomodoro:
            return "🍅"
        case .shortBreak:
            return "☕️"
        case .longBreak:
            return "🏖️"
        }
    }
}
