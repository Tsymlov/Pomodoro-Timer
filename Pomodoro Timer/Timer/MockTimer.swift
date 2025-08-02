//
//  MockTimer.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation
import Combine

final class MockTimer: TimerProtocol {
    private let subject = PassthroughSubject<Date, Never>()
    private var isActive = false

    var publisher: AnyPublisher<Date, Never> {
        subject.eraseToAnyPublisher()
    }

    func start() {
        isActive = true
    }

    func stop() {
        isActive = false
    }

    func simulateTick() {
        if isActive {
            subject.send(Date())
        }
    }
}
