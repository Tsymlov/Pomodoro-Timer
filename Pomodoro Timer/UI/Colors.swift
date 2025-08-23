//
//  Colors.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 17.08.2025.
//

import SwiftUI

enum Colors {
    // MARK: - Session Colors
    static let pomodoro = Color.accent
    static let shortBreak = Color.blue
    static let longBreak = Color.purple
    static let completed = Color.green
    
    // MARK: - Opacity Values
    static let sessionBackgroundOpacity = 0.1
    static let progressBackgroundOpacity = 0.2
    static let sessionBorderOpacity = 0.3

    // MARK: - Button Colors
    static let resetButton = Color.orange
    static let resetButtonBackground = Color.orange.opacity(0.1)
    static let skipButton = Color.blue
    static let skipButtonBackground = Color.blue.opacity(0.1)
    static let mainButtonText = Color.white

    // MARK: - Text Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary

    // MARK: - Background Colors
    #if os(macOS)
    static let appBackground = Color(NSColor.textBackgroundColor)
    static let progressBackground = Color(NSColor.tertiaryLabelColor)
    static let progressFillBackground = Color.clear
    #else
    static let appBackground = Color(UIColor.systemBackground)
    static let progressBackground = Color(UIColor.tertiaryLabel)
    static let progressFillBackground = Color.clear
    #endif

}
    // MARK: - Session Color Helper
extension SessionType {
    var color: Color {
        switch self {
        case .pomodoro:
            return Colors.pomodoro
        case .shortBreak:
            return Colors.shortBreak
        case .longBreak:
            return Colors.longBreak
        }
    }
}
