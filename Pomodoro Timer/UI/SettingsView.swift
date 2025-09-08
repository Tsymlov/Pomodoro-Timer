//
//  SettingsView.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 08.09.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: Store
    @State private var pomodoroDuration: Double
    @State private var shortBreakDuration: Double
    @State private var longBreakDuration: Double
    @State private var dailyGoal: Double
    @State private var autoStartBreaks: Bool
    @State private var autoStartPomodoros: Bool
    @State private var soundEnabled: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    init(store: Store) {
        self.store = store
        let settings = store.settings
        _pomodoroDuration = State(initialValue: settings.pomodoroDuration / 60)
        _shortBreakDuration = State(initialValue: settings.shortBreakDuration / 60)
        _longBreakDuration = State(initialValue: settings.longBreakDuration / 60)
        _dailyGoal = State(initialValue: Double(settings.dailyGoal))
        _autoStartBreaks = State(initialValue: settings.autoStartBreaks)
        _autoStartPomodoros = State(initialValue: settings.autoStartPomodoros)
        _soundEnabled = State(initialValue: settings.soundEnabled)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(spacing: Constants.settingsSectionSpacing) {
                    timerDurationsSection
                    goalsSection
                    automationSection
                    notificationsSection
                }
                .padding()
            }
            
            buttonsView
        }
        .frame(width: Constants.settingsWindowWidth, height: Constants.settingsWindowHeight)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text(Strings.Settings.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Timer Durations Section
    private var timerDurationsSection: some View {
        SettingsSection(title: Strings.Settings.timerDurations) {
            VStack(spacing: Constants.settingsRowSpacing) {
                DurationRow(
                    title: Strings.Settings.pomodoro,
                    value: $pomodoroDuration,
                    range: Constants.pomodoroMinDuration...Constants.pomodoroMaxDuration,
                    icon: "timer",
                    color: .red
                )
                
                DurationRow(
                    title: Strings.Settings.shortBreak,
                    value: $shortBreakDuration,
                    range: Constants.shortBreakMinDuration...Constants.shortBreakMaxDuration,
                    icon: "cup.and.saucer",
                    color: .blue
                )
                
                DurationRow(
                    title: Strings.Settings.longBreak,
                    value: $longBreakDuration,
                    range: Constants.longBreakMinDuration...Constants.longBreakMaxDuration,
                    icon: "moon",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Goals Section
    private var goalsSection: some View {
        SettingsSection(title: Strings.Settings.goals) {
            HStack {
                Label(Strings.Settings.dailyGoal, systemImage: "target")
                    .foregroundColor(.orange)
                    .frame(width: Constants.settingsLabelWidth, alignment: .leading)
                
                Slider(value: $dailyGoal, in: Constants.dailyGoalMin...Constants.dailyGoalMax, step: 1)
                    .accentColor(.orange)
                
                Text(String(format: Strings.Settings.pomodorosFormat, Int(dailyGoal)))
                    .font(.system(.body, design: .monospaced))
                    .frame(width: Constants.settingsPomodorosLabelWidth, alignment: .trailing)
            }
        }
    }
    
    // MARK: - Automation Section
    private var automationSection: some View {
        SettingsSection(title: Strings.Settings.automation) {
            VStack(spacing: Constants.settingsRowSpacing) {
                ToggleRow(
                    title: Strings.Settings.autoStartBreaks,
                    isOn: $autoStartBreaks,
                    icon: "play.circle",
                    color: .green
                )
                
                ToggleRow(
                    title: Strings.Settings.autoStartPomodoros,
                    isOn: $autoStartPomodoros,
                    icon: "repeat.circle",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        SettingsSection(title: Strings.Settings.notifications) {
            ToggleRow(
                title: Strings.Settings.soundNotifications,
                isOn: $soundEnabled,
                icon: Strings.Icons.speakerWave,
                color: .indigo
            )
        }
    }
    
    // MARK: - Buttons
    private var buttonsView: some View {
        HStack {
            Button(Strings.Settings.cancel) {
                dismiss()
            }
            .keyboardShortcut(.escape)
            
            Spacer()
            
            Button(Strings.Settings.resetToDefaults) {
                resetToDefaults()
            }
            
            Button(Strings.Settings.save) {
                saveSettings()
            }
            .keyboardShortcut(.return)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Actions
    private func resetToDefaults() {
        pomodoroDuration = Constants.pomodoroDuration / 60
        shortBreakDuration = Constants.shortBreakDuration / 60
        longBreakDuration = Constants.longBreakDuration / 60
        dailyGoal = Double(Constants.defaultDailyGoal)
        autoStartBreaks = false
        autoStartPomodoros = false
        soundEnabled = true
    }
    
    private func saveSettings() {
        var newSettings = store.settings
        newSettings.pomodoroDuration = pomodoroDuration * 60
        newSettings.shortBreakDuration = shortBreakDuration * 60
        newSettings.longBreakDuration = longBreakDuration * 60
        newSettings.dailyGoal = Int(dailyGoal)
        newSettings.autoStartBreaks = autoStartBreaks
        newSettings.autoStartPomodoros = autoStartPomodoros
        newSettings.soundEnabled = soundEnabled
        
        store.send(.updateSettings(newSettings))
        dismiss()
    }
}

// MARK: - Subviews
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.settingsPadding) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: Constants.settingsRowSpacing) {
                content
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(Constants.cornerRadius)
        }
    }
}

struct DurationRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(color)
                .frame(width: Constants.settingsLabelWidth, alignment: .leading)
            
            Slider(value: $value, in: range, step: 1)
                .accentColor(color)
            
            Text(String(format: Strings.Settings.minutesFormat, Int(value)))
                .font(.system(.body, design: .monospaced))
                .frame(width: Constants.settingsMinutesLabelWidth, alignment: .trailing)
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Label(title, systemImage: icon)
                .foregroundColor(color)
        }
    }
}

#Preview {
    SettingsView(store: Store())
}