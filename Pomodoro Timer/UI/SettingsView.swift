//
//  SettingsView.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 08.09.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: Store
    @Environment(\.dismiss) private var dismiss
    
    private var editingSettings: Settings {
        store.editingSettings ?? store.settings
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            settingsContent
            buttonsView
        }
        .frame(width: Constants.settingsWindowWidth, height: Constants.settingsWindowHeight)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            store.send(.beginEditingSettings)
        }
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
    
    // MARK: - Settings Content
    private var settingsContent: some View {
        ScrollView {
            VStack(spacing: Constants.settingsSectionSpacing) {
                timerDurationsSection
                goalsSection
                automationSection
                notificationsSection
            }
            .padding()
        }
    }
    
    // MARK: - Sections
    private var timerDurationsSection: some View {
        SettingsSection(title: Strings.Settings.timerDurations) {
            VStack(spacing: Constants.settingsRowSpacing) {
                ForEach(TimerDurationType.allCases, id: \.self) { type in
                    DurationRow(
                        type: type,
                        value: binding(for: type)
                    )
                }
            }
        }
    }
    
    private var goalsSection: some View {
        SettingsSection(title: Strings.Settings.goals) {
            SliderRow(
                title: Strings.Settings.dailyGoal,
                value: Binding(
                    get: { Double(editingSettings.dailyGoal) },
                    set: { store.send(.updateEditingDailyGoal($0)) }
                ),
                range: Constants.dailyGoalMin...Constants.dailyGoalMax,
                step: 1,
                icon: Strings.Icons.target,
                color: .orange,
                format: { String(format: Strings.Settings.pomodorosFormat, Int($0)) }
            )
        }
    }
    
    private var automationSection: some View {
        SettingsSection(title: Strings.Settings.automation) {
            VStack(spacing: Constants.settingsRowSpacing) {
                ToggleRow(
                    title: Strings.Settings.autoStartBreaks,
                    isOn: Binding(
                        get: { editingSettings.autoStartBreaks },
                        set: { store.send(.updateEditingAutoStartBreaks($0)) }
                    ),
                    icon: Strings.Icons.playCircle,
                    color: .green
                )
                
                ToggleRow(
                    title: Strings.Settings.autoStartPomodoros,
                    isOn: Binding(
                        get: { editingSettings.autoStartPomodoros },
                        set: { store.send(.updateEditingAutoStartPomodoros($0)) }
                    ),
                    icon: Strings.Icons.repeatCircle,
                    color: .green
                )
            }
        }
    }
    
    private var notificationsSection: some View {
        SettingsSection(title: Strings.Settings.notifications) {
            ToggleRow(
                title: Strings.Settings.soundNotifications,
                isOn: Binding(
                    get: { editingSettings.soundEnabled },
                    set: { store.send(.updateEditingSoundEnabled($0)) }
                ),
                icon: Strings.Icons.speakerWave,
                color: .indigo
            )
        }
    }
    
    // MARK: - Buttons
    private var buttonsView: some View {
        HStack {
            Button(Strings.Settings.cancel) {
                store.send(.cancelEditingSettings)
                dismiss()
            }
            .keyboardShortcut(.escape)
            
            Spacer()
            
            Button(Strings.Settings.resetToDefaults) {
                store.send(.resetEditingSettingsToDefaults)
            }
            
            Button(Strings.Settings.save) {
                store.send(.saveEditingSettings)
                dismiss()
            }
            .keyboardShortcut(.return)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Helper Methods
    private func binding(for type: TimerDurationType) -> Binding<Double> {
        switch type {
        case .pomodoro:
            return Binding(
                get: { editingSettings.pomodoroDuration / Constants.secondsPerMinute },
                set: { store.send(.updateEditingPomodoroDuration($0)) }
            )
        case .shortBreak:
            return Binding(
                get: { editingSettings.shortBreakDuration / Constants.secondsPerMinute },
                set: { store.send(.updateEditingShortBreakDuration($0)) }
            )
        case .longBreak:
            return Binding(
                get: { editingSettings.longBreakDuration / Constants.secondsPerMinute },
                set: { store.send(.updateEditingLongBreakDuration($0)) }
            )
        }
    }
}

// MARK: - Timer Duration Type
enum TimerDurationType: CaseIterable {
    case pomodoro
    case shortBreak
    case longBreak
    
    var title: String {
        switch self {
        case .pomodoro:
            return Strings.Settings.pomodoro
        case .shortBreak:
            return Strings.Settings.shortBreak
        case .longBreak:
            return Strings.Settings.longBreak
        }
    }
    
    var icon: String {
        switch self {
        case .pomodoro:
            return Strings.Icons.timer
        case .shortBreak:
            return Strings.Icons.cupAndSaucer
        case .longBreak:
            return Strings.Icons.moon
        }
    }
    
    var color: Color {
        switch self {
        case .pomodoro:
            return .red
        case .shortBreak:
            return .blue
        case .longBreak:
            return .purple
        }
    }
    
    var range: ClosedRange<Double> {
        switch self {
        case .pomodoro:
            return Constants.pomodoroMinDuration...Constants.pomodoroMaxDuration
        case .shortBreak:
            return Constants.shortBreakMinDuration...Constants.shortBreakMaxDuration
        case .longBreak:
            return Constants.longBreakMinDuration...Constants.longBreakMaxDuration
        }
    }
}

// MARK: - Reusable Components
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
    let type: TimerDurationType
    @Binding var value: Double
    
    var body: some View {
        HStack {
            Label(type.title, systemImage: type.icon)
                .foregroundColor(type.color)
                .frame(width: Constants.settingsLabelWidth, alignment: .leading)
            
            Slider(value: Binding(
                get: { value },
                set: { newValue in value = round(newValue) }
            ), in: type.range)
                .accentColor(type.color)
            
            Text(String(format: Strings.Settings.minutesFormat, Int(value)))
                .font(.system(.body, design: .monospaced))
                .frame(width: Constants.settingsMinutesLabelWidth, alignment: .trailing)
        }
    }
}

struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let icon: String
    let color: Color
    let format: (Double) -> String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(color)
                .frame(width: Constants.settingsLabelWidth, alignment: .leading)
            
            Slider(value: Binding(
                get: { value },
                set: { newValue in value = round(newValue / step) * step }
            ), in: range)
                .accentColor(color)
            
            Text(format(value))
                .font(.system(.body, design: .monospaced))
                .frame(width: Constants.settingsPomodorosLabelWidth, alignment: .trailing)
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