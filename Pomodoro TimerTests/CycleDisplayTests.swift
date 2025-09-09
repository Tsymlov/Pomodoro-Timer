//
//  CycleDisplayTests.swift
//  Pomodoro TimerTests
//
//  Created by Alexey Tsymlov on 08.09.2025.
//

import XCTest
@testable import Pomodoro_Timer

final class CycleDisplayTests: XCTestCase {
    
    var store: Store!
    
    override func setUp() {
        super.setUp()
        store = Store()
    }
    
    override func tearDown() {
        store = nil
        super.tearDown()
    }
    
    // MARK: - Basic Display Tests
    
    func testEmptyDisplay_NoPomodoros() {
        // Given
        store.state.statistics.todayStats.completedPomodoros = 0
        store.state.statistics.todayStats.completedLongBreaks = 0
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertEqual(display, "", "Should show empty string when no pomodoros completed")
    }
    
    func testSingleCycle_OnePomodoro() {
        // Given
        store.state.statistics.todayStats.completedPomodoros = 1
        store.state.statistics.todayStats.completedLongBreaks = 0
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertEqual(display, "1×", "Should show 1× for single pomodoro")
    }
    
    func testSingleCycle_FourPomodoros() {
        // Given
        store.state.statistics.todayStats.completedPomodoros = 4
        store.state.statistics.todayStats.completedLongBreaks = 0
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertEqual(display, "4×", "Should show 4× for full cycle without long break")
    }
    
    // MARK: - Multiple Cycles Tests
    
    func testTwoCycles_CompletedFirstCycle() {
        // Given - 4 pomodoros and 1 long break = completed first cycle
        store.state.statistics.todayStats.completedPomodoros = 4
        store.state.statistics.todayStats.completedLongBreaks = 1
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertEqual(display, "4×", "Should show 4× after completing first cycle")
    }
    
    func testTwoCycles_WithSecondCycleProgress() {
        // Given - 6 pomodoros and 1 long break
        store.state.statistics.todayStats.completedPomodoros = 6
        store.state.statistics.todayStats.completedLongBreaks = 1
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertEqual(display, "4× 2×", "Should show 4× 2× for first complete cycle plus 2 in second")
    }
    
    func testThreeCycles_TwoCompletedOneCurrent() {
        // Given - 9 pomodoros and 2 long breaks
        store.state.statistics.todayStats.completedPomodoros = 9
        store.state.statistics.todayStats.completedLongBreaks = 2
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertEqual(display, "4× 4× 1×", "Should show 4× 4× 1× for two complete cycles plus 1")
    }
    
    // MARK: - Edge Cases
    
    func testManualLongBreak_PartialCycle() {
        // Given - Manual long break after 2 pomodoros
        store.state.statistics.todayStats.completedPomodoros = 2
        store.state.statistics.todayStats.completedLongBreaks = 1
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertEqual(display, "2×", "Should show 2× for partial cycle with manual long break")
    }
    
    func testManualLongBreak_MultipleCycles() {
        // Given - Mix of manual and automatic long breaks
        // 2 pomodoros, long break, 3 pomodoros, long break, 1 pomodoro
        store.state.statistics.todayStats.completedPomodoros = 6
        store.state.statistics.todayStats.completedLongBreaks = 2
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        // First cycle gets 4 pomodoros max, second gets 2, third gets remaining
        XCTAssertEqual(display, "4× 2×", "Should distribute pomodoros across cycles")
    }
    
    func testManyPomodoros_NoLongBreaks() {
        // Given - Many pomodoros without taking long breaks
        store.state.statistics.todayStats.completedPomodoros = 10
        store.state.statistics.todayStats.completedLongBreaks = 0
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertEqual(display, "10×", "Should show all pomodoros in single group without long breaks")
    }
    
    func testExcessiveLongBreaks_FewerPomodoros() {
        // Given - More long breaks than expected (manual breaks)
        store.state.statistics.todayStats.completedPomodoros = 5
        store.state.statistics.todayStats.completedLongBreaks = 3
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertEqual(display, "4× 1×", "Should handle excess long breaks gracefully")
    }
    
    // MARK: - Current Cycle Tests
    
    func testCurrentCycle_CalculatedCorrectly() {
        // Given
        store.state.statistics.todayStats.completedLongBreaks = 2
        
        // When
        let currentCycle = store.currentCycle
        
        // Then
        XCTAssertEqual(currentCycle, 3, "Current cycle should be number of long breaks + 1")
    }
    
    func testCurrentCycle_AfterMoveToNextSession() {
        // Given
        var state = AppState()
        state.currentSession = .longBreak
        state.currentCycle = 1
        
        // When - Complete long break and move to next session
        reducer(state: &state, action: .moveToNextSession)
        
        // Then
        XCTAssertEqual(state.currentCycle, 2, "Cycle should increment after long break completion")
        XCTAssertEqual(state.currentSession, .pomodoro, "Should move to pomodoro after long break")
    }
    
    // MARK: - Display Formatting Tests
    
    func testDisplay_ProperSpacing() {
        // Given
        store.state.statistics.todayStats.completedPomodoros = 8
        store.state.statistics.todayStats.completedLongBreaks = 1
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertTrue(display.contains(" "), "Should have space between cycle groups")
        XCTAssertEqual(display, "4× 4×", "Should format with single space between groups")
    }
    
    func testDisplay_UnicodeMultiplicationSign() {
        // Given
        store.state.statistics.todayStats.completedPomodoros = 1
        store.state.statistics.todayStats.completedLongBreaks = 0
        
        // When
        let display = store.todayPomodorosCyclesDisplay
        
        // Then
        XCTAssertTrue(display.contains("×"), "Should use × (multiplication sign) not x")
    }
}