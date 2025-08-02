//
//  SystemTimer.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation
import Combine

final class SystemTimer: TimerProtocol {
    private var timer: Timer?
    private let interval: TimeInterval

    var publisher: AnyPublisher<Date, Never> {
        Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }

    init(interval: TimeInterval = Constants.timeInterval) {
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
