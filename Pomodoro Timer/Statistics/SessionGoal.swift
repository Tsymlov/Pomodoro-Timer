//
//  SessionGoal.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 03.08.2025.
//

import Foundation

struct SessionGoal: Equatable, Codable {
    let id: UUID
    let sessionType: SessionType
    let text: String
    let createdAt: Date
    var isCompleted: Bool = false

    init(sessionType: SessionType, text: String) {
        self.id = UUID()
        self.sessionType = sessionType
        self.text = text
        self.createdAt = Date()
        self.isCompleted = false
    }
}
