//
//  Constants.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 02.08.2025.
//

import Foundation

enum Constants {
    // MARK: - Timer Durations
    static let pomodoroDuration: TimeInterval = 25 * 60 // 25 minutes
    static let shortBreakDuration: TimeInterval = 5 * 60 // 5 minutes
    static let longBreakDuration: TimeInterval = 15 * 60 // 15 minutes
    static let timeInterval: TimeInterval = 1 // 1 second
    static let pomodorosUntilLongBreak = 4
    
    // MARK: - UI Sizes
    static let menuBarIconSize: CGFloat = 16
    static let menuTimerViewWidth: CGFloat = 200
    static let menuTimerViewHeight: CGFloat = 44
    static let menuProgressSize: CGFloat = 24
    static let menuProgressLineWidth: CGFloat = 3
    static let menuPadding: CGFloat = 16
    static let menuTimeLabelSpacing: CGFloat = 12
    static let menuTimeLabelHeight: CGFloat = 28
    static let menuTimeLabelWidth: CGFloat = 120
    static let menuContentApproximateWidth: CGFloat = 80
    
    // MARK: - Animation
    static let animationDuration: TimeInterval = 0.3
    static let windowCreationDelay: TimeInterval = 0.5
    static let menuUpdateInterval: TimeInterval = 1.0
    
    // MARK: - Layout
    static let cornerRadius: CGFloat = 12
    static let dashPattern: [CGFloat] = [5]
    static let borderWidth: CGFloat = 1.0
    static let strokeInset: CGFloat = 3
    
    // MARK: - Menu Bar Icon
    static let menuBarCircleInset: CGFloat = 1.5
    static let menuBarBorderInset: CGFloat = 0.5
    static let menuBarBackgroundAlpha: CGFloat = 0.2
    static let menuBarProgressStartAngle: CGFloat = 90
    static let menuBarProgressFullCircle: CGFloat = 360
    
    // MARK: - Timer Circle Sizes
    #if os(iOS)
    static let timerCircleSize: CGFloat = 280
    static let timerLineWidth: CGFloat = 12
    #else
    static let timerCircleSize: CGFloat = 200
    static let timerLineWidth: CGFloat = 10
    #endif
}
