//
//  DailyStats.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

struct DailyStats: Equatable, Codable {
    let date: Date
    var completedPomodoros: Int = 0
    var completedShortBreaks: Int = 0
    var completedLongBreaks: Int = 0
    var totalFocusTime: TimeInterval = 0
    var sessions: [SessionRecord] = []

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    var pomodorosByHour: [Int: Int] {
        Dictionary(grouping: sessions.filter { $0.sessionType == .pomodoro && $0.wasCompleted }) { session in
            Calendar.current.component(.hour, from: session.startTime)
        }.mapValues { $0.count }
    }

    var averageSessionDuration: TimeInterval {
        let completedSessions = sessions.filter { $0.wasCompleted }
        guard !completedSessions.isEmpty else { return 0 }
        return completedSessions.map { $0.duration }.reduce(0, +) / Double(completedSessions.count)
    }
}
