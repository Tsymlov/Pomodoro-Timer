//
//  TimerState.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

enum TimerState: Equatable {
    case idle
    case running
    case paused
    case completed

    var isActive: Bool {
        self == .running
    }

    var displayName: String {
        switch self {
        case .idle:
            return "Ready to start"
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        case .completed:
            return "Completed"
        }
    }
}
