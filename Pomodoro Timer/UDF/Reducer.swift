//
//  Reducer.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

func reducer(state: inout AppState, action: Action) {
    switch action {
    case .start:
        guard state.canStart else { return }
        state.timerState = .running
        state.currentSessionStartTime = Date()

    case .pause:
        guard state.canPause else { return }
        state.timerState = .paused

    case .resume:
        guard state.timerState == .paused else { return }
        state.timerState = .running

    case .stop:
        recordCurrentSession(state: &state, wasCompleted: false)
        state.timerState = .idle
        state.timeRemaining = state.getCurrentSessionDuration()
        state.currentSessionStartTime = nil

    case .reset:
        recordCurrentSession(state: &state, wasCompleted: false)
        state.timerState = .idle
        state.timeRemaining = state.getCurrentSessionDuration()
        state.statistics.currentStreak = 0
        state.currentSessionStartTime = nil

    case .tick:
        guard state.timerState == .running else { return }

        if state.timeRemaining > 0 {
            state.timeRemaining -= 1
        } else {
            // Session completed
            recordCurrentSession(state: &state, wasCompleted: true)
            updateStatisticsForCompletion(state: &state)
            state.timerState = .completed
        }

    case .complete:
        if state.timerState == .running {
            recordCurrentSession(state: &state, wasCompleted: true)
            updateStatisticsForCompletion(state: &state)
            state.timerState = .completed
        }

    case .moveToNextSession:
        moveToNextSession(state: &state)

    case .skipToBreak:
        if state.currentSession == .pomodoro {
            recordCurrentSession(state: &state, wasCompleted: true)
            updateStatisticsForCompletion(state: &state)
            moveToNextSession(state: &state)
        }

    case .skipToPomodoro:
        if state.currentSession != .pomodoro {
            recordCurrentSession(state: &state, wasCompleted: false)
            state.currentSession = .pomodoro
            state.timeRemaining = state.settings.pomodoroDuration
            state.timerState = .idle
            state.currentSessionStartTime = nil
        }

    case .updateSettings(let newSettings):
        state.settings = newSettings

        // If timer is not running, update current time
        if state.timerState == .idle {
            state.timeRemaining = state.getCurrentSessionDuration()
        }

    case .setDailyGoal(let goal):
        state.statistics.dailyGoal = max(1, goal)

    case .resetDailyStatistics:
        state.statistics = TimerStatistics(dailyGoal: state.statistics.dailyGoal)
        state.currentCycle = 1

    case .showGoalInput:
        state.isGoalInputPresented = true

    case .hideGoalInput:
        state.isGoalInputPresented = false

    case .setGoal(let goalText):
        if !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let newGoal = SessionGoal(sessionType: state.currentSession, text: goalText)
            state.currentGoal = newGoal
            state.allGoals.append(newGoal) // ADD: save to history
        }
        state.isGoalInputPresented = false
    }
}

// MARK: - Reducer Helper Functions
private func recordCurrentSession(state: inout AppState, wasCompleted: Bool) {
    guard let startTime = state.currentSessionStartTime else { return }

    let endTime = Date()
    let actualDuration = endTime.timeIntervalSince(startTime)

    let record = SessionRecord(
        sessionType: state.currentSession,
        startTime: startTime,
        endTime: endTime,
        duration: actualDuration,
        wasCompleted: wasCompleted,
        goalId: state.currentGoal?.id
    )

    state.statistics = state.statistics.addSessionRecord(record)
}

private func updateStatisticsForCompletion(state: inout AppState) {
    switch state.currentSession {
    case .pomodoro:
        state.statistics.completedPomodoros += 1
        state.statistics.totalFocusTime += state.settings.pomodoroDuration
        state.statistics.currentStreak += 1
    case .shortBreak:
        state.statistics.completedShortBreaks += 1
    case .longBreak:
        state.statistics.completedLongBreaks += 1
    }
}

private func moveToNextSession(state: inout AppState) {
    switch state.currentSession {
    case .pomodoro:
        // After pomodoro comes break
        if state.statistics.completedPomodoros % Constants.pomodorosUntilLongBreak == 0 {
            state.currentSession = .longBreak
            state.currentCycle += 1
        } else {
            state.currentSession = .shortBreak
        }
    case .shortBreak, .longBreak:
        // After break comes pomodoro
        state.currentSession = .pomodoro
    }

    state.timeRemaining = state.getCurrentSessionDuration()
    state.timerState = .idle
    state.currentSessionStartTime = nil
    state.currentGoal = nil // Clear goal when moving to next session
}
