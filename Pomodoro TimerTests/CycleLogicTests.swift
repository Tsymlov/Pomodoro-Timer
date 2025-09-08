//
//  CycleLogicTests.swift
//  Pomodoro TimerTests
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import XCTest
@testable import Pomodoro_Timer

final class CycleLogicTests: XCTestCase {
    
    // MARK: - Cycle Increment Logic
    
    func testCycleIncrements_AfterLongBreakCompletion() {
        // Given
        var state = AppState()
        state.currentSession = .longBreak
        state.currentCycle = 1
        state.timerState = .idle
        
        // When - Move from long break to next session (pomodoro)
        reducer(state: &state, action: .moveToNextSession)
        
        // Then
        XCTAssertEqual(state.currentCycle, 2, "Cycle should increment after completing long break")
        XCTAssertEqual(state.currentSession, .pomodoro, "Should move to pomodoro after long break")
    }
    
    func testCycleDoesNotIncrement_WhenStartingLongBreak() {
        // Given
        var state = AppState()
        state.currentSession = .pomodoro
        state.currentCycle = 1
        state.timerState = .idle
        state.statistics.todayStats.completedPomodoros = 4
        
        // When - Move from 4th pomodoro to long break
        reducer(state: &state, action: .moveToNextSession)
        
        // Then
        XCTAssertEqual(state.currentCycle, 1, "Cycle should NOT increment when starting long break")
        XCTAssertEqual(state.currentSession, .longBreak, "Should move to long break after 4th pomodoro")
    }
    
    func testCycleDoesNotIncrement_WhenManuallyStartingLongBreak() {
        // Given
        var state = AppState()
        state.currentCycle = 1
        state.timerState = .idle
        
        // When - Manually start long break
        reducer(state: &state, action: .startLongBreak)
        
        // Then
        XCTAssertEqual(state.currentCycle, 1, "Cycle should NOT increment when manually starting long break")
        XCTAssertEqual(state.currentSession, .longBreak, "Should be in long break session")
    }
    
    // MARK: - Pomodoro Counting Logic
    
    func testPomodoroCount_IncreasesOnlyAfterCompletion() {
        // Given
        var state = AppState()
        state.currentSession = .pomodoro
        state.timerState = .running
        state.statistics.completedPomodoros = 0
        state.timeRemaining = 0
        state.currentSessionStartTime = Date()
        state.sessionEndTime = Date()
        
        // When - Complete pomodoro naturally via timer update
        reducer(state: &state, action: .updateBackgroundTime)
        
        // Then
        XCTAssertEqual(state.statistics.completedPomodoros, 1, "Pomodoro count should increase after natural completion")
    }
    
    func testPomodoroCount_DoesNotIncreaseWhenSkippingToBreak() {
        // Given
        var state = AppState()
        state.currentSession = .pomodoro
        state.timerState = .idle
        state.statistics.completedPomodoros = 0
        
        // When - Skip to break without completing pomodoro
        reducer(state: &state, action: .skipToBreak)
        
        // Then
        XCTAssertEqual(state.statistics.completedPomodoros, 0, "Pomodoro count should NOT increase when skipping to break")
        XCTAssertTrue(state.currentSession == .shortBreak || state.currentSession == .longBreak, "Should be in break session")
    }
    
    // MARK: - Session Transition Logic
    
    func testSessionTransition_AfterFirstPomodoro() {
        // Given
        var state = AppState()
        state.currentSession = .pomodoro
        state.statistics.todayStats.completedPomodoros = 1
        
        // When
        reducer(state: &state, action: .moveToNextSession)
        
        // Then
        XCTAssertEqual(state.currentSession, .shortBreak, "Should move to short break after 1st pomodoro")
    }
    
    func testSessionTransition_AfterFourthPomodoro() {
        // Given
        var state = AppState()
        state.currentSession = .pomodoro
        state.statistics.todayStats.completedPomodoros = 4
        
        // When
        reducer(state: &state, action: .moveToNextSession)
        
        // Then
        XCTAssertEqual(state.currentSession, .longBreak, "Should move to long break after 4th pomodoro")
    }
    
    func testSessionTransition_AfterShortBreak() {
        // Given
        var state = AppState()
        state.currentSession = .shortBreak
        state.currentCycle = 1
        
        // When
        reducer(state: &state, action: .moveToNextSession)
        
        // Then
        XCTAssertEqual(state.currentSession, .pomodoro, "Should move to pomodoro after short break")
        XCTAssertEqual(state.currentCycle, 1, "Cycle should not change after short break")
    }
    
    // MARK: - Daily Reset Logic
    
    func testDailyReset_ResetsCycleToOne() {
        // Given
        var state = AppState()
        state.currentCycle = 5
        state.statistics.completedPomodoros = 20
        
        // When
        reducer(state: &state, action: .resetDailyStatistics)
        
        // Then
        XCTAssertEqual(state.currentCycle, 1, "Cycle should reset to 1 on daily reset")
        XCTAssertEqual(state.statistics.completedPomodoros, 0, "Pomodoro count should reset")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStatistics_HandlesCorrectly() {
        // Given
        var state = AppState()
        state.statistics.todayStats.completedPomodoros = 0
        state.currentSession = .pomodoro
        
        // When
        reducer(state: &state, action: .moveToNextSession)
        
        // Then
        XCTAssertEqual(state.currentSession, .shortBreak, "Should move to short break when no pomodoros completed")
    }
    
    func testMultipleCycles_TracksCorrectly() {
        // Given
        var state = AppState()
        state.currentSession = .longBreak
        state.currentCycle = 3
        
        // When - Complete multiple cycles
        reducer(state: &state, action: .moveToNextSession) // Long break -> Pomodoro, cycle 4
        XCTAssertEqual(state.currentCycle, 4)
        
        state.currentSession = .longBreak
        reducer(state: &state, action: .moveToNextSession) // Long break -> Pomodoro, cycle 5
        
        // Then
        XCTAssertEqual(state.currentCycle, 5, "Should correctly track multiple cycle increments")
    }
}
