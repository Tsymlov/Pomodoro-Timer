//
//  TimerView.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 27.07.2025.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var store = Store()
    @State private var goalText = ""
    @State private var showingGoalInput = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {

                Spacer()

                // MARK: - Main Timer Circle
                timerCircle

                Spacer()

                // MARK: - Goal Section
                goalSection

                // MARK: - Control Buttons
                controlButtons

                Spacer()
            }
            .padding()
            .navigationTitle(store.currentSession.title)
            .modifier(PlatformNavigationModifier())
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    settingsButton
                }
            }
            .sheet(isPresented: $showingGoalInput) {
                goalInputSheet
            }
        }
    }

    // MARK: - Goal Section
    private var goalSection: some View {
        Group {
            if let goal = store.currentGoal {
                goalDisplay(goal)
            } else {
                goalPlaceholder
            }
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
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundColor(.primary)

                Text(store.timerState.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Text("Cycle \(store.currentCycle)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
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

    // MARK: - Goal Display
    private func goalDisplay(_ goal: SessionGoal) -> some View {
        VStack(spacing: 8) {
            Text("Session Goal")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text(goal.text)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(sessionColor, lineWidth: 1)
                )
        )
    }

    // MARK: - Goal Placeholder
    private var goalPlaceholder: some View {
        Button(action: {
            showingGoalInput = true
        }) {
            VStack(spacing: 4) {
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("Set a goal for this session")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Goal Input Sheet
    private var goalInputSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("What's your goal for this \(store.currentSession.title.lowercased()) session?")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.top)

#if os(iOS)
                AutoFocusTextField(text: $goalText, placeholder: "Enter your goal...")
                    .frame(height: 44)
                    .padding(.horizontal)
#else
                TextField("Enter your goal...", text: $goalText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
#endif

                Spacer()
            }
            .padding()
            .navigationTitle("Session Goal")
            .modifier(PlatformNavigationModifier())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingGoalInput = false
                        goalText = ""
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.setGoal(goalText))
                        showingGoalInput = false
                        goalText = ""
                    }
                    .disabled(goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            goalText = store.currentGoal?.text ?? ""
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

// MARK: - Platform Navigation Modifier
struct PlatformNavigationModifier: ViewModifier {
    func body(content: Content) -> some View {
#if os(iOS)
        content.navigationBarTitleDisplayMode(.inline)
#else
        content
#endif
    }
}

// MARK: - Preview
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
