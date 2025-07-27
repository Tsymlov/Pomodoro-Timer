//
//  PomodoroTimerTests.swift
//
//  Created by Alexey Tsymlov on 27.07.2025.
//

import XCTest
import Combine
@testable import Pomodoro_Timer

// MARK: - Mock Timer for Testing
final class MockTimer: TimerProtocol {
    private let subject = PassthroughSubject<Date, Never>()
    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0

    var publisher: AnyPublisher<Date, Never> {
        subject.eraseToAnyPublisher()
    }

    func start() {
        startCallCount += 1
    }

    func stop() {
        stopCallCount += 1
    }

    func simulateTick() {
        subject.send(Date())
    }

    func reset() {
        startCallCount = 0
        stopCallCount = 0
    }
}

// MARK: - Tests
final class PomodoroTimerTests: XCTestCase {
    private var pomodoroTimer: PomodoroTimer!
    private var mockTimer: MockTimer!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockTimer = MockTimer()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        pomodoroTimer = nil
        mockTimer = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization_WithDefaultDuration() {
        // Given & When
        pomodoroTimer = PomodoroTimer(timer: mockTimer)

        // Then
        XCTAssertEqual(pomodoroTimer.countDownTime, 1500, "Should initialize with default 25 minutes (1500 seconds)")
        XCTAssertFalse(pomodoroTimer.isRunning, "Should not be running initially")
    }

    func testInitialization_WithCustomDuration() {
        // Given
        let customDuration: CGFloat = 600 // 10 minutes

        // When
        pomodoroTimer = PomodoroTimer(duration: customDuration, timer: mockTimer)

        // Then
        XCTAssertEqual(pomodoroTimer.countDownTime, customDuration, "Should initialize with custom duration")
        XCTAssertFalse(pomodoroTimer.isRunning, "Should not be running initially")
    }

    // MARK: - Toggle Tests

    func testToggle_StartsTimer() {
        // Given
        pomodoroTimer = PomodoroTimer(timer: mockTimer)

        // When
        pomodoroTimer.toggle()

        // Then
        XCTAssertTrue(pomodoroTimer.isRunning, "Should be running after toggle")
        XCTAssertEqual(mockTimer.startCallCount, 1, "Should call start on timer")
        XCTAssertEqual(mockTimer.stopCallCount, 0, "Should not call stop on timer")
    }

    func testToggle_StopsTimer() {
        // Given
        pomodoroTimer = PomodoroTimer(timer: mockTimer)
        pomodoroTimer.toggle() // Start first
        mockTimer.reset()

        // When
        pomodoroTimer.toggle() // Stop

        // Then
        XCTAssertFalse(pomodoroTimer.isRunning, "Should not be running after second toggle")
        XCTAssertEqual(mockTimer.startCallCount, 0, "Should not call start on timer")
        XCTAssertEqual(mockTimer.stopCallCount, 1, "Should call stop on timer")
    }

    func testToggle_MultipleToggles() {
        // Given
        pomodoroTimer = PomodoroTimer(timer: mockTimer)

        // When & Then
        pomodoroTimer.toggle()
        XCTAssertTrue(pomodoroTimer.isRunning, "Should be running after first toggle")

        pomodoroTimer.toggle()
        XCTAssertFalse(pomodoroTimer.isRunning, "Should not be running after second toggle")

        pomodoroTimer.toggle()
        XCTAssertTrue(pomodoroTimer.isRunning, "Should be running after third toggle")
    }

    // MARK: - Reset Tests

    func testReset_StopsTimerAndResetsTime() {
        // Given
        let customDuration: CGFloat = 300
        pomodoroTimer = PomodoroTimer(duration: customDuration, timer: mockTimer)
        pomodoroTimer.toggle() // Start timer

        // Simulate some time passing
        mockTimer.simulateTick()
        mockTimer.simulateTick()

        // When
        pomodoroTimer.reset()

        // Then
        XCTAssertFalse(pomodoroTimer.isRunning, "Should not be running after reset")
        XCTAssertEqual(pomodoroTimer.countDownTime, customDuration, "Should reset to original duration")
        XCTAssertEqual(mockTimer.stopCallCount, 1, "Should call stop on timer")
    }

    func testReset_WhenNotRunning() {
        // Given
        let customDuration: CGFloat = 300
        pomodoroTimer = PomodoroTimer(duration: customDuration, timer: mockTimer)

        // When
        pomodoroTimer.reset()

        // Then
        XCTAssertFalse(pomodoroTimer.isRunning, "Should remain not running")
        XCTAssertEqual(pomodoroTimer.countDownTime, customDuration, "Should maintain original duration")
    }

    // MARK: - Tick Tests

    func testTick_DecreasesTime() {
        // Given
        pomodoroTimer = PomodoroTimer(duration: 10, timer: mockTimer)
        pomodoroTimer.toggle() // Start timer

        // When
        mockTimer.simulateTick()

        // Then
        XCTAssertEqual(pomodoroTimer.countDownTime, 9, "Should decrease by 1 second")
    }

    func testTick_DoesNotDecreaseWhenNotRunning() {
        // Given
        pomodoroTimer = PomodoroTimer(duration: 10, timer: mockTimer)
        // Timer is not started

        // When
        mockTimer.simulateTick()

        // Then
        XCTAssertEqual(pomodoroTimer.countDownTime, 10, "Should not change when not running")
    }

    func testTick_MultipleTicks() {
        // Given
        pomodoroTimer = PomodoroTimer(duration: 10, timer: mockTimer)
        pomodoroTimer.toggle() // Start timer

        // When
        mockTimer.simulateTick()
        mockTimer.simulateTick()
        mockTimer.simulateTick()

        // Then
        XCTAssertEqual(pomodoroTimer.countDownTime, 7, "Should decrease by 3 seconds")
    }

    func testTick_CompletesTimer() {
        // Given
        pomodoroTimer = PomodoroTimer(duration: 2, timer: mockTimer)
        pomodoroTimer.toggle() // Start timer

        // When - simulate ticks until completion
        mockTimer.simulateTick() // 1 second left
        XCTAssertEqual(pomodoroTimer.countDownTime, 1)
        XCTAssertTrue(pomodoroTimer.isRunning, "Should still be running")

        mockTimer.simulateTick() // 0 seconds left
        XCTAssertEqual(pomodoroTimer.countDownTime, 0)
        XCTAssertTrue(pomodoroTimer.isRunning, "Should still be running at 0")

        mockTimer.simulateTick() // Timer should complete and reset

        // Then
        XCTAssertEqual(pomodoroTimer.countDownTime, 2, "Should reset to original duration")
        XCTAssertFalse(pomodoroTimer.isRunning, "Should not be running after completion")
    }

    // MARK: - Published Properties Tests

    func testIsRunningPublished() {
        // Given
        pomodoroTimer = PomodoroTimer(timer: mockTimer)
        var receivedValues: [Bool] = []

        let expectation = XCTestExpectation(description: "isRunning published")
        expectation.expectedFulfillmentCount = 3 // Initial value + 2 changes

        pomodoroTimer.$isRunning
            .sink { value in
                receivedValues.append(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        pomodoroTimer.toggle() // Start
        pomodoroTimer.toggle() // Stop

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues, [false, true, false], "Should publish isRunning changes")
    }

    func testCountDownTimePublished() {
        // Given
        pomodoroTimer = PomodoroTimer(duration: 5, timer: mockTimer)
        var receivedValues: [CGFloat] = []

        let expectation = XCTestExpectation(description: "countDownTime published")
        expectation.expectedFulfillmentCount = 4 // Initial + 3 ticks

        pomodoroTimer.$countDownTime
            .sink { value in
                receivedValues.append(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        pomodoroTimer.toggle() // Start
        mockTimer.simulateTick()
        mockTimer.simulateTick()
        mockTimer.simulateTick()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues, [5, 4, 3, 2], "Should publish countDownTime changes")
    }

    // MARK: - Edge Cases

    func testZeroDuration() {
        // Given & When
        pomodoroTimer = PomodoroTimer(duration: 0, timer: mockTimer)
        pomodoroTimer.toggle()

        // Then
        mockTimer.simulateTick()
        XCTAssertEqual(pomodoroTimer.countDownTime, 0, "Should reset to 0")
        XCTAssertFalse(pomodoroTimer.isRunning, "Should stop immediately")
    }

    func testNegativeDuration() {
        // Given & When
        pomodoroTimer = PomodoroTimer(duration: -5, timer: mockTimer)
        pomodoroTimer.toggle()

        // Then
        mockTimer.simulateTick()
        XCTAssertEqual(pomodoroTimer.countDownTime, -5, "Should reset to original negative value")
        XCTAssertFalse(pomodoroTimer.isRunning, "Should stop immediately")
    }

    // MARK: - Memory Management Tests

    func testMemoryManagement() {
        // Given
        weak var weakTimer: PomodoroTimer?

        // When
        autoreleasepool {
            let timer = PomodoroTimer(timer: mockTimer)
            weakTimer = timer
            // timer goes out of scope
        }

        // Then
        XCTAssertNil(weakTimer, "PomodoroTimer should be deallocated")
    }
}
