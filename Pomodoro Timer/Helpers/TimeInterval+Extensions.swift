//
//  TimeInterval+Extensions.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

extension TimeInterval {
    var minutesAndSeconds: (minutes: Int, seconds: Int) {
        let totalSeconds = Int(self)
        return (minutes: totalSeconds / 60, seconds: totalSeconds % 60)
    }

    var formattedMinutesSeconds: String {
        let (minutes, seconds) = minutesAndSeconds
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
