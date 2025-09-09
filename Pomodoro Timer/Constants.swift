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
    
    // MARK: - Settings Window
    static let settingsWindowWidth: CGFloat = 450
    static let settingsWindowHeight: CGFloat = 680
    static let settingsSectionSpacing: CGFloat = 20
    static let settingsRowSpacing: CGFloat = 12
    static let settingsPadding: CGFloat = 15
    static let settingsLabelWidth: CGFloat = 120
    static let settingsMinutesLabelWidth: CGFloat = 60
    static let settingsPomodorosLabelWidth: CGFloat = 100
    
    // MARK: - Settings Ranges
    static let pomodoroMinDuration: Double = 1
    static let pomodoroMaxDuration: Double = 60
    static let shortBreakMinDuration: Double = 1
    static let shortBreakMaxDuration: Double = 30
    static let longBreakMinDuration: Double = 1
    static let longBreakMaxDuration: Double = 60
    static let dailyGoalMin: Double = 1
    static let dailyGoalMax: Double = 20
    static let defaultDailyGoal: Int = 8
    
    // MARK: - Settings Defaults
    static let defaultAutoStartBreaks: Bool = false
    static let defaultAutoStartPomodoros: Bool = false
    static let defaultSoundEnabled: Bool = true
    
    // MARK: - Time Conversion
    static let secondsPerMinute: Double = 60
    
    // MARK: - Goal Input Sheet
    static let goalInputSheetMinWidth: CGFloat = 400
    static let goalInputSheetMinHeight: CGFloat = 200
    static let goalInputSheetSpacing: CGFloat = 20
    static let goalInputSheetDetentHeight: CGFloat = 200
    static let goalInputTextFieldHeight: CGFloat = 44
    
    // MARK: - Control Buttons
    #if os(iOS)
    static let controlButtonSize: CGFloat = 50
    static let mainControlButtonSize: CGFloat = 80
    static let controlButtonSpacing: CGFloat = 20
    #else
    static let controlButtonSize: CGFloat = 40
    static let mainControlButtonSize: CGFloat = 64
    static let controlButtonSpacing: CGFloat = 16
    #endif
    static let controlButtonPaddingHorizontal: CGFloat = 20
    static let controlButtonPaddingVertical: CGFloat = 12
    static let controlButtonCornerRadius: CGFloat = 25
    static let mainButtonAnimationDuration: Double = 0.2
    static let mainButtonScaleRunning: CGFloat = 1.1
    static let mainButtonScaleNormal: CGFloat = 1.0
    
    // MARK: - Timer View
    static let timerViewSpacing: CGFloat = 20
    static let timerViewPaddingHorizontal: CGFloat = 15
    static let timerViewPaddingVertical: CGFloat = 10
    static let timerCyclesSpacing: CGFloat = 6
    static let timerCyclesMaxWidth: CGFloat = 200
    static let timerCyclesPaddingTop: CGFloat = 10
    static let goalPlaceholderSpacing: CGFloat = 4
}
