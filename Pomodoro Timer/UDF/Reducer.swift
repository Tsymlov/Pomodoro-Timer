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
        state.sessionEndTime = Date().addingTimeInterval(state.timeRemaining)

    case .resume:
        guard state.timerState == .paused else { return }
        state.timerState = .running
        
        let timeToResume = state.pausedTimeRemaining ?? state.timeRemaining
        state.timeRemaining = timeToResume
        state.sessionEndTime = Date().addingTimeInterval(timeToResume)
        state.pausedTimeRemaining = nil

    case .stop:
        recordCurrentSession(state: &state, wasCompleted: false)
        state.timerState = .idle
        state.timeRemaining = state.getCurrentSessionDuration()
        state.currentSessionStartTime = nil
        state.pausedTimeRemaining = nil

    case .reset:
        recordCurrentSession(state: &state, wasCompleted: false)
        state.timerState = .idle
        state.timeRemaining = state.getCurrentSessionDuration()
        state.statistics.currentStreak = 0
        state.currentSessionStartTime = nil
        state.pausedTimeRemaining = nil

    case .pause:
        guard state.canPause else { return }
        state.timerState = .paused
        state.pausedTimeRemaining = state.timeRemaining
        state.sessionEndTime = nil

    case .enterBackground:
        state.backgroundTime = Date()

    case .enterForeground:
        guard state.backgroundTime != nil else { return }

        if state.timerState == .running {
            updateTimerProgress(state: &state)
        }

        state.backgroundTime = nil

    case .updateBackgroundTime, .tick:
        updateTimerProgress(state: &state)

    case .complete:
        // Completion is handled in updateTimerProgress
        // This action is kept for compatibility but doesn't do anything
        break

    case .moveToNextSession:
        moveToNextSession(state: &state)

    case .skipToBreak:
        if state.currentSession == .pomodoro {
            recordCurrentSession(state: &state, wasCompleted: false)
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

    case .startShortBreak:
        startBreakSession(state: &state, sessionType: .shortBreak)

    case .startLongBreak:
        startBreakSession(state: &state, sessionType: .longBreak)

    case .updateSettings(let newSettings):
        state.settings = newSettings

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
        let todayPomodoros = state.statistics.todayStats.completedPomodoros
        if todayPomodoros > 0 && todayPomodoros % Constants.pomodorosUntilLongBreak == 0 {
            state.currentSession = .longBreak
        } else {
            state.currentSession = .shortBreak
        }
    case .shortBreak:
        state.currentSession = .pomodoro
    case .longBreak:
        state.currentSession = .pomodoro
        state.currentCycle += 1
    }

    state.timeRemaining = state.getCurrentSessionDuration()
    state.timerState = .idle
    state.currentSessionStartTime = nil
}

// MARK: - Helper Functions

private func startBreakSession(state: inout AppState, sessionType: SessionType) {
    // Allow starting break from any state except paused
    guard state.timerState != .paused else { return }
    
    // If transitioning from running session, record it
    if state.timerState == .running {
        // Record current session as incomplete
        recordCurrentSession(state: &state, wasCompleted: false)
        
        // If switching from one break to another break type
        if (state.currentSession == .shortBreak || state.currentSession == .longBreak) && 
           (sessionType == .shortBreak || sessionType == .longBreak) {
            // Just switching break types, no additional logic needed
        }
    }

    state.currentSession = sessionType
    state.timeRemaining = state.getCurrentSessionDuration()
    state.timerState = .running
    state.currentSessionStartTime = Date()
    state.sessionEndTime = Date().addingTimeInterval(state.timeRemaining)
}

private func updateTimerProgress(state: inout AppState) {
    guard state.timerState == .running else { return }
    guard let endTime = state.sessionEndTime else { return }

    let now = Date()

    if now >= endTime {
        recordCurrentSession(state: &state, wasCompleted: true)
        updateStatisticsForCompletion(state: &state)
        state.timerState = .completed
        state.timeRemaining = 0
    } else {
        state.timeRemaining = endTime.timeIntervalSince(now)
    }
}
