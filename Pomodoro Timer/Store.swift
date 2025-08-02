//
//  Store.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

@MainActor
final class Store: ObservableObject {
    @Published private(set) var model: PomodoroTimerModel

    init(model: PomodoroTimerModel = PomodoroTimerModel()) {
        self.model = model
    }

    func send(_ action: TimerAction) {
        model.perform(action)
    }

    // MARK: - Convenience Getters
    var state: TimerState { model.state }
    var currentSession: SessionType { model.currentSession }
    var timeRemaining: TimeInterval { model.timeRemaining }
    var formattedTime: String { model.formattedTime }
    var progress: Double { model.progress }
    var statistics: TimerStatistics { model.statistics }
    var currentCycle: Int { model.currentCycle }
    var canStart: Bool { model.canStart }
    var canPause: Bool { model.canPause }
    var canReset: Bool { model.canReset }
}
