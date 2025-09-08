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
        _pomodoroDuration = State(initialValue: store.settings.pomodoroDuration / 60)
        _shortBreakDuration = State(initialValue: store.settings.shortBreakDuration / 60)
        _longBreakDuration = State(initialValue: store.settings.longBreakDuration / 60)
        _dailyGoal = State(initialValue: Double(store.settings.dailyGoal))
        _autoStartBreaks = State(initialValue: store.settings.autoStartBreaks)
        _autoStartPomodoros = State(initialValue: store.settings.autoStartPomodoros)
        _soundEnabled = State(initialValue: store.settings.soundEnabled)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(spacing: 20) {
                    timerDurationsSection
                    goalsSection
                    automationSection
                    notificationsSection
                }
                .padding()
            }
            
            buttonsView
        }
        .frame(width: 450, height: 550)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var headerView: some View {
        HStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var timerDurationsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Timer Durations")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                durationRow(
                    title: "Pomodoro",
                    value: $pomodoroDuration,
                    range: 1...60,
                    color: .red
                )
                
                durationRow(
                    title: "Short Break",
                    value: $shortBreakDuration,
                    range: 1...30,
                    color: .blue
                )
                
                durationRow(
                    title: "Long Break",
                    value: $longBreakDuration,
                    range: 1...60,
                    color: .purple
                )
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
    
    private func durationRow(title: String, value: Binding<Double>, range: ClosedRange<Double>, color: Color) -> some View {
        HStack {
            Label(title, systemImage: iconForSession(title))
                .foregroundColor(color)
                .frame(width: 120, alignment: .leading)
            
            Slider(value: value, in: range, step: 1)
                .accentColor(color)
            
            Text("\(Int(value.wrappedValue)) min")
                .font(.system(.body, design: .monospaced))
                .frame(width: 60, alignment: .trailing)
        }
    }
    
    private func iconForSession(_ title: String) -> String {
        switch title {
        case "Pomodoro":
            return "timer"
        case "Short Break":
            return "cup.and.saucer"
        case "Long Break":
            return "moon"
        default:
            return "clock"
        }
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Goals")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                HStack {
                    Label("Daily Goal", systemImage: "target")
                        .foregroundColor(.orange)
                        .frame(width: 120, alignment: .leading)
                    
                    Slider(value: $dailyGoal, in: 1...20, step: 1)
                        .accentColor(.orange)
                    
                    Text("\(Int(dailyGoal)) pomodoros")
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 100, alignment: .trailing)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
    
    private var automationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Automation")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Toggle(isOn: $autoStartBreaks) {
                    Label("Auto-start breaks", systemImage: "play.circle")
                        .foregroundColor(.green)
                }
                
                Toggle(isOn: $autoStartPomodoros) {
                    Label("Auto-start pomodoros", systemImage: "repeat.circle")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Notifications")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Toggle(isOn: $soundEnabled) {
                    Label("Sound notifications", systemImage: "speaker.wave.2")
                        .foregroundColor(.indigo)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
    
    private var buttonsView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.escape)
            
            Spacer()
            
            Button("Reset to Defaults") {
                resetToDefaults()
            }
            
            Button("Save") {
                saveSettings()
                dismiss()
            }
            .keyboardShortcut(.return)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func resetToDefaults() {
        pomodoroDuration = Constants.pomodoroDuration / 60
        shortBreakDuration = Constants.shortBreakDuration / 60
        longBreakDuration = Constants.longBreakDuration / 60
        dailyGoal = 8
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
    }
}

#Preview {
    SettingsView(store: Store())
}
