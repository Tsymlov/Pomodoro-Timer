//
//  SessionRecort.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

struct SessionRecord: Equatable, Codable, Identifiable {
    let id = UUID()
    let sessionType: SessionType
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let wasCompleted: Bool

    var day: Date {
        Calendar.current.startOfDay(for: startTime)
    }

    var startHour: Int {
        Calendar.current.component(.hour, from: startTime)
    }

    var startMinute: Int {
        Calendar.current.component(.minute, from: startTime)
    }

    var timeOfDay: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
}
