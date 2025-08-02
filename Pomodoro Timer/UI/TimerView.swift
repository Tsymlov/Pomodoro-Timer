//
//  TimerView.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 27.07.2025.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var store = Store()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {

                // MARK: - Session Header
                sessionHeader

                // MARK: - Main Timer Circle
                timerCircle

                // MARK: - Control Buttons
                controlButtons

                // MARK: - Statistics
                statisticsSection

                Spacer()
            }
            .padding()
            .navigationTitle("Pomodoro Timer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsButton
                }
            }
        }
    }

    // MARK: - Session Header
    private var sessionHeader: some View {
        VStack(spacing: 8) {
            Text(store.currentSession.emoji)
                .font(.system(size: 60))
                .animation(.easeInOut, value: store.currentSession)

            Text(store.currentSession.title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text("Cycle \(store.currentCycle)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Timer Circle
    private var timerCircle: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                .frame(width: 280, height: 280)

            // Progress circle
            Circle()
                .trim(from: 0, to: store.progress)
                .stroke(
                    sessionColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: store.progress)

            // Time display
            VStack(spacing: 4) {
                Text(store.formattedTime)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(.primary)

                Text(store.timerState.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
            }
        }
    }

    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 20) {
            // Reset Button
            Button(action: { store.send(.reset) }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .frame(width: 50, height: 50)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Circle())
            }
            .disabled(!store.canReset)

            // Main Action Button
            Button(action: mainButtonAction) {
                Image(systemName: mainButtonIcon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(sessionColor)
                    .clipShape(Circle())
                    .scaleEffect(store.timerState == .running ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: store.timerState)
            }

            // Skip Button
            Button(action: skipButtonAction) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: 12) {
            HStack {
                StatCard(
                    title: "Today",
                    value: "\(store.todayStats.completedPomodoros)",
                    subtitle: "pomodoros",
                    color: .red
                )

                StatCard(
                    title: "Streak",
                    value: "\(store.statistics.currentStreak)",
                    subtitle: "days",
                    color: .orange
                )

                StatCard(
                    title: "Goal",
                    value: "\(Int(store.statistics.progressToGoal * 100))%",
                    subtitle: "complete",
                    color: .green
                )
            }

            // Progress bar for daily goal
            ProgressView(value: store.statistics.progressToGoal)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .scaleEffect(y: 2)
        }
    }

    // MARK: - Settings Button
    private var settingsButton: some View {
        Button(action: {
            // Handle settings action
        }) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.gray)
        }
    }

    // MARK: - Computed Properties
    private var sessionColor: Color {
        switch store.currentSession {
        case .pomodoro:
            return .red
        case .shortBreak:
            return .blue
        case .longBreak:
            return .purple
        }
    }

    private var mainButtonIcon: String {
        switch store.timerState {
        case .idle, .completed:
            return "play.fill"
        case .running:
            return "pause.fill"
        case .paused:
            return "play.fill"
        }
    }

    private func mainButtonAction() {
        switch store.timerState {
        case .idle, .completed:
            store.send(.start)
        case .running:
            store.send(.pause)
        case .paused:
            store.send(.resume)
        }
    }

    private func skipButtonAction() {
        switch store.currentSession {
        case .pomodoro:
            store.send(.skipToBreak)
        case .shortBreak, .longBreak:
            store.send(.skipToPomodoro)
        }
    }
}

// MARK: - Statistics Card Component
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
