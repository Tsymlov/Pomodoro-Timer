//
//  TimerProtocol.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation
import Combine

protocol TimerProtocol {
    var publisher: AnyPublisher<Date, Never> { get }
    func start()
    func stop()
}
