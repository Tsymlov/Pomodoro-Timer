//
//  Fonts.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 17.08.2025.
//

import SwiftUI

enum Fonts {
    // MARK: - Timer Display Fonts
    #if os(iOS)
    static let timerDisplay = Font.system(size: 64, weight: .heavy).monospacedDigit()
    #else
    static let timerDisplay = Font.system(size: 42, weight: .heavy).monospacedDigit()
    #endif
    static let timerCycles = Font.system(size: 16, weight: .heavy)
    
    // MARK: - Button Fonts
    static let mainButton = Font.title
    static let secondaryButton = Font.title2
    
    // MARK: - Text Fonts
    static let body = Font.body
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let headline = Font.headline
    
    // MARK: - Menu Timer Fonts (macOS)
    #if os(macOS)
    static let menuTimerFontSize: CGFloat = 24
    static let menuReadyFontSize: CGFloat = 20
    
    static func menuTimerFont() -> NSFont {
        return NSFont.monospacedDigitSystemFont(ofSize: menuTimerFontSize, weight: .bold)
    }
    
    static func menuReadyFont() -> NSFont {
        return NSFont.systemFont(ofSize: menuReadyFontSize, weight: .medium)
    }
    #endif
}
