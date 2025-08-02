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

    static let userDefaultsKey = "Settings"

    static func load() -> Settings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(Settings.self, from: data) else {
            return Settings()
        }
        return settings
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }
    }
}
