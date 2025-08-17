//
//  TimerStatistics.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

struct TimerStatistics: Equatable, Codable {
    var completedPomodoros: Int = 0
    var completedShortBreaks: Int = 0
    var completedLongBreaks: Int = 0
    var totalFocusTime: TimeInterval = 0
    var currentStreak: Int = 0
    var dailyGoal: Int = 8
    var sessionHistory: [SessionRecord] = []
    var dailyStats: [String: DailyStats] = [:] // Key: yyyy-MM-dd

    var isGoalAchieved: Bool {
        completedPomodoros >= dailyGoal
    }

    var progressToGoal: Double {
        min(Double(completedPomodoros) / Double(dailyGoal), 1.0)
    }

    // MARK: - Analytics Methods
    var todayStats: DailyStats {
        let today = Calendar.current.startOfDay(for: Date())
        let dateKey = dateKey(for: today)
        return dailyStats[dateKey] ?? DailyStats(date: today)
    }

    var last7DaysStats: [DailyStats] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).compactMap { daysBack in
            guard let date = calendar.date(byAdding: .day, value: -daysBack, to: today) else { return nil }
            let key = dateKey(for: date)
            return dailyStats[key] ?? DailyStats(date: date)
        }.reversed()
    }

    var last30DaysStats: [DailyStats] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<30).compactMap { daysBack in
            guard let date = calendar.date(byAdding: .day, value: -daysBack, to: today) else { return nil }
            let key = dateKey(for: date)
            return dailyStats[key] ?? DailyStats(date: date)
        }.reversed()
    }

    var weeklyAverage: Double {
        let stats = last7DaysStats
        let totalPomodoros = stats.map { $0.completedPomodoros }.reduce(0, +)
        return Double(totalPomodoros) / 7.0
    }

    var mostProductiveHour: Int? {
        let allHourlyData = dailyStats.values.flatMap { $0.pomodorosByHour }
        let hourCounts = Dictionary(grouping: allHourlyData, by: { $0.key })
            .mapValues { $0.map { $0.value }.reduce(0, +) }

        return hourCounts.max(by: { $0.value < $1.value })?.key
    }

    var longestStreak: Int {
        var maxStreak = 0
        var currentStreakCount = 0

        let sortedDays = dailyStats.values.sorted { $0.date < $1.date }

        for day in sortedDays {
            if day.completedPomodoros > 0 {
                currentStreakCount += 1
                maxStreak = max(maxStreak, currentStreakCount)
            } else {
                currentStreakCount = 0
            }
        }

        return maxStreak
    }

    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func addSessionRecord(_ record: SessionRecord) -> TimerStatistics {
        var newStats = self
        let dayKey = dateKey(for: record.day)

        // Add to session history
        newStats.sessionHistory.append(record)

        // Update daily stats
        var dayStats = newStats.dailyStats[dayKey] ?? DailyStats(date: record.day)
        dayStats.sessions.append(record)

        if record.wasCompleted {
            switch record.sessionType {
            case .pomodoro:
                dayStats.completedPomodoros += 1
                dayStats.totalFocusTime += record.duration
            case .shortBreak:
                dayStats.completedShortBreaks += 1
            case .longBreak:
                dayStats.completedLongBreaks += 1
            }
        }

        newStats.dailyStats[dayKey] = dayStats

        return newStats
    }
}

// MARK: - Session Goal Analytics
extension TimerStatistics {
    // Group sessions by goal text (combines goals with same name)
    func sessionsByGoalText(goals: [SessionGoal]) -> [String: [SessionRecord]] {
        let goalsById = Dictionary(uniqueKeysWithValues: goals.map { ($0.id, $0) })

        return Dictionary(grouping: sessionHistory.compactMap { record -> (String, SessionRecord)? in
            guard let goalId = record.goalId,
                  let goalText = goalsById[goalId]?.text else { return nil }
            return (goalText, record)
        }, by: { $0.0 })
        .mapValues { $0.map { $0.1 } }
    }

    // Statistics for goal text (combined)
    func statsForGoalText(_ goalText: String, goals: [SessionGoal]) -> (sessions: [SessionRecord], totalTime: TimeInterval, completedSessions: Int) {
        let goalsById = Dictionary(uniqueKeysWithValues: goals.map { ($0.id, $0) })

        let goalSessions = sessionHistory.filter { record in
            guard let goalId = record.goalId,
                  let goal = goalsById[goalId] else { return false }
            return goal.text == goalText
        }

        let totalTime = goalSessions.filter { $0.wasCompleted }.reduce(0) { $0 + $1.duration }
        let completed = goalSessions.filter { $0.wasCompleted }.count

        return (goalSessions, totalTime, completed)
    }

    // List of unique goal texts for reports
    func uniqueGoalTexts(goals: [SessionGoal]) -> [String] {
        let goalsById = Dictionary(uniqueKeysWithValues: goals.map { ($0.id, $0) })

        let goalTexts = sessionHistory.compactMap { record in
            record.goalId.flatMap { goalsById[$0]?.text }
        }

        return Array(Set(goalTexts)).sorted()
    }
}

// MARK: - Cycles Analytics
extension TimerStatistics {
    /// Total number of complete cycles (every 4 pomodoros)
    var totalCompletedCycles: Int {
        completedPomodoros / Constants.pomodorosUntilLongBreak
    }

    /// Number of pomodoros in the current incomplete cycle
    var pomodorosInCurrentCycle: Int {
        completedPomodoros % Constants.pomodorosUntilLongBreak
    }

    /// Complete cycles for today
    var todayCompletedCycles: Int {
        todayStats.completedPomodoros / Constants.pomodorosUntilLongBreak
    }

    /// Pomodoros in current cycle today
    var todayPomodorosInCurrentCycle: Int {
        todayStats.completedPomodoros % Constants.pomodorosUntilLongBreak
    }

    /// Progress to next long break (0.0 - 1.0)
    var progressToLongBreak: Double {
        let pomodorosInCycle = Double(pomodorosInCurrentCycle)
        return pomodorosInCycle / Double(Constants.pomodorosUntilLongBreak)
    }

    /// Progress to next long break for today (0.0 - 1.0)
    var todayProgressToLongBreak: Double {
        let pomodorosInCycle = Double(todayPomodorosInCurrentCycle)
        return pomodorosInCycle / Double(Constants.pomodorosUntilLongBreak)
    }

    /// Average number of cycles per day for the last 7 days
    var averageCyclesPerDay: Double {
        let totalCycles = last7DaysStats.map { $0.completedPomodoros / Constants.pomodorosUntilLongBreak }.reduce(0, +)
        return Double(totalCycles) / 7.0
    }

    /// Best day by number of cycles in the last month
    var bestCycleDay: (date: Date, cycles: Int)? {
        let dayWithMostCycles = last30DaysStats.max { first, second in
            let firstCycles = first.completedPomodoros / Constants.pomodorosUntilLongBreak
            let secondCycles = second.completedPomodoros / Constants.pomodorosUntilLongBreak
            return firstCycles < secondCycles
        }

        guard let bestDay = dayWithMostCycles else { return nil }
        let cycles = bestDay.completedPomodoros / Constants.pomodorosUntilLongBreak
        return (bestDay.date, cycles)
    }
}
