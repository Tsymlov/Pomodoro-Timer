//
//  Pomodoro_TimerTests.swift
//  Pomodoro TimerTests
//
//  Created by Alexey Tsymlov on 11.05.2025.
//

import Testing
@testable import Pomodoro_Timer

struct Pomodoro_TimerTests {

    @Test func testSessionTypeDurations() async throws {
        // Test that session types have correct durations
        #expect(SessionType.pomodoro.duration == 25 * 60)
        #expect(SessionType.shortBreak.duration == 5 * 60)
        #expect(SessionType.longBreak.duration == 15 * 60)
    }

    @Test func testConstants() async throws {
        // Test that constants are correctly defined
        #expect(Constants.pomodoroDuration == 25 * 60)
        #expect(Constants.shortBreakDuration == 5 * 60)
        #expect(Constants.longBreakDuration == 15 * 60)
        #expect(Constants.timeInterval == 1)
        #expect(Constants.pomodorosUntilLongBreak == 4)
    }

    @Test func testTimerState() async throws {
        // Test timer state properties
        #expect(TimerState.idle.isActive == false)
        #expect(TimerState.running.isActive == true)
        #expect(TimerState.paused.isActive == false)
        #expect(TimerState.completed.isActive == false)
    }

    @Test func testSessionGoal() async throws {
        // Test session goal creation
        let goal = SessionGoal(sessionType: .pomodoro, text: "Test goal")
        #expect(goal.sessionType == .pomodoro)
        #expect(goal.text == "Test goal")
        #expect(goal.id != UUID())
    }
}
