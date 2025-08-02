//
//  PomodoroTimer.swift
//
//  Created by Alexey Tsymlov on 27.07.2025.
//

import Foundation
import Combine

// MARK: - Pomodoro Timer
final class PomodoroTimer: ObservableObject {
    let duration: CGFloat

    @Published var isRunning: Bool = false
    @Published var countDownTime: CGFloat

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
