//
//  PomodoroTimer.swift
//
//  Created by Alexey Tsymlov on 27.07.2025.
//

import Foundation
import Combine

// MARK: - Constants
private enum Constants {
    static let pomodoroDuration: CGFloat = 1500 // secs. It is 25 mins.
}

// MARK: - Timer Protocol
protocol TimerProtocol {
    var publisher: AnyPublisher<Date, Never> { get }
    func start()
    func stop()
}

// MARK: - Real Timer Implementation
final class SystemTimer: TimerProtocol {
    private var timer: Timer?
    private let interval: TimeInterval

    var publisher: AnyPublisher<Date, Never> {
        Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }

    init(interval: TimeInterval = 1.0) {
        self.interval = interval
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Pomodoro Timer
final class PomodoroTimer: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var countDownTime: CGFloat

    private let duration: CGFloat
    private let timer: TimerProtocol
    private var cancellables = Set<AnyCancellable>()

    init(duration: CGFloat = Constants.pomodoroDuration, timer: TimerProtocol = SystemTimer()) {
        self.duration = duration
        self.countDownTime = duration
        self.timer = timer

        setupTimer()
    }

    private func setupTimer() {
        timer.publisher
            .sink { [weak self] _ in
                self?.tick()
            }
            .store(in: &cancellables)
    }

    func toggle() {
        isRunning.toggle()
        if isRunning {
            timer.start()
        } else {
            timer.stop()
        }
    }

    func reset() {
        isRunning = false
        countDownTime = duration
        timer.stop()
    }

    private func tick() {
        guard isRunning else { return }

        if countDownTime > 0 {
            countDownTime -= 1
        } else {
            reset()
        }
    }
}
