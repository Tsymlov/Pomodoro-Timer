//
//  Strings.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 08.09.2025.
//

import Foundation

enum Strings {
    // MARK: - Settings
    enum Settings {
        static let title = "Settings"
        static let timerDurations = "Timer Durations"
        static let goals = "Goals"
        static let automation = "Automation"
        static let notifications = "Notifications"
        
        static let pomodoro = "Pomodoro"
        static let shortBreak = "Short Break"
        static let longBreak = "Long Break"
        static let dailyGoal = "Daily Goal"
        
        static let autoStartBreaks = "Auto-start breaks"
        static let autoStartPomodoros = "Auto-start pomodoros"
        static let soundNotifications = "Sound notifications"
        
        static let cancel = "Cancel"
        static let resetToDefaults = "Reset to Defaults"
        static let save = "Save"
        
        static let minutesFormat = "%d min"
        static let pomodorosFormat = "%d pomodoros"
    }
    
    // MARK: - Menu Bar
    enum MenuBar {
        static let resumeTimer = "Resume Timer"
        static let startTimer = "Start Focus"
        static let pauseTimer = "Pause Timer"
        static let resetTimer = "Reset Timer"
        static let startShortBreak = "Start Short Break"
        static let startLongBreak = "Start Long Break"
        static let showPomodoroTimer = "Show Pomodoro Timer"
        static let quitPomodoroTimer = "Quit Pomodoro Timer"
    }
    
    // MARK: - Sessions
    enum Sessions {
        static let focus = "Focus"
        static let shortBreak = "Short Break"
        static let longBreak = "Long Break"
    }
    
    // MARK: - Timer
    enum Timer {
        static let ready = "Ready"
        static let setGoal = "Set a goal for this session"
        static let sessionGoal = "Session Goal"
        static let cancel = "Cancel"
        static let save = "Save"
    }
    
    // MARK: - Icons
    enum Icons {
        static let timer = "timer"
        static let cupAndSaucer = "cup.and.saucer"
        static let cupAndSaucerFill = "cup.and.saucer.fill"
        static let moon = "moon"
        static let target = "target"
        static let playCircle = "play.circle"
        static let playFill = "play.fill"
        static let repeatCircle = "repeat.circle"
        static let speakerWave = "speaker.wave.2"
        static let gearshape = "gearshape.fill"
        static let stopFill = "stop.fill"
        static let forwardFill = "forward.fill"
        static let arrowCounterclockwise = "arrow.counterclockwise"
    }
}